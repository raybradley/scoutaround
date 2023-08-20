# frozen_string_literal: true

# a landscape view printable calendar with three columns (generally one column
# per month)
class Pdf::FridgeCalendar < Prawn::Document
  MAX_COLUMN_COUNT = 3
  MAX_ROW_COUNT = 10
  GUTTER = 20
  MONTH_HEADER_HEIGHT = 2
  COLOR_TEXT_LIGHT = "888888"
  COLOR_BRAND = "E66425"
  PAGE_HEADER_HEIGHT = 50

  def initialize(unit, events)
    super(page_layout: :landscape)
    @unit = unit
    @events = events
    render_calendar
  end

  def filename
    "#{@unit.name} Schedule as of #{DateTime.now.in_time_zone(@unit.settings(:locale).time_zone).strftime('%d %B %Y')}.pdf"
  end

  def render_calendar
    define_grid(columns: 3, rows: 1, gutter: 20)
    @current_column = 0

    @presenter = EventPresenter.new
    @presenter.plain_text = true

    render_page_header

    @events_by_month = @events.group_by { |e| [e.starts_at.year, e.starts_at.month] }

    @events_by_month.each do |year_month, events|
      @year, @month = year_month
      index = 0
      event_count = events.count
      columns_in_month = (event_count / MAX_ROW_COUNT.to_f).ceil
      month_header_width = [@current_column + columns_in_month, MAX_COLUMN_COUNT].min
      @current_month_column = 0

      grid([0, @current_column], [0, month_header_width - 1]).bounding_box do
        move_down PAGE_HEADER_HEIGHT
        render_month_header
      end

      columns_in_month.times do
        grid(0, @current_column).bounding_box do
          @current_row = 0
          move_down 10 + PAGE_HEADER_HEIGHT

          MAX_ROW_COUNT.times do
            @event = events[index]
            render_event
            index += 1
            break if index >= event_count

            @current_row += 1
            if @current_row > MAX_ROW_COUNT
              @current_column += 1
              @current_row = 0
            end
          end

          @current_month_column += 1
        end

        @current_column += 1

        if @current_column >= MAX_COLUMN_COUNT
          start_new_page
          render_page_header
          @current_column = 0

          # if current month isn't done
          if @current_month_column < columns_in_month
            month_header_width = [columns_in_month - @current_month_column, MAX_COLUMN_COUNT].min
            grid([0, @current_column], [0, month_header_width - 1]).bounding_box do
              move_down PAGE_HEADER_HEIGHT
              render_month_header
            end
          end
        end
      end
    end
  end

  def render_page_header
    grid([0, 0], [0, MAX_COLUMN_COUNT - 1]).bounding_box do
      formatted_text [
        { text: "#{@unit.name} Schedule".upcase, size: 18, styles: [:bold], kerning: true }
      ]
      formatted_text [
        { text: "As of #{DateTime.now.in_time_zone(@unit.settings(:locale).time_zone).strftime('%B %-d, %Y')}".upcase,
          size: 10, styles: [:bold], kerning: true }
      ]
    end
  end

  def render_month_header
    month_header = Date::MONTHNAMES[@month]

    if @current_year.nil? || @year != @current_year
      month_header = "#{Date::MONTHNAMES[@month]} #{@year}"
      @current_year = @year
    end

    month_header += " (cont.)" if @current_month_column.positive?

    formatted_text [
      { text: month_header, size: 16, styles: [:bold], color: COLOR_BRAND, kerning: true }
    ]
    self.line_width = 1
    stroke_horizontal_rule
  end

  def render_event
    @presenter.event = @event
    self.line_width = 0.5

    move_down 10
    stroke_horizontal_rule if @current_row > 0
    move_down 10

    # date and day
    formatted_text_box(
      [
        { text: @presenter.dates_to_s, size: 21, styles: [:bold] },
        { text: "\n" + @presenter.days_to_s.upcase, size: 9, styles: [:bold], color: COLOR_TEXT_LIGHT }
      ],
      at: [0, cursor]
    )

    # title and location
    formatted_text_box(
      [
        { text: @event.title, size: 10, styles: [:bold] },
        { text: "\n#{@event.location}", styles: [:bold], size: 10, color: COLOR_TEXT_LIGHT }
      ],
      at: [70, cursor]
    )

    move_down 25

  end
end

  # def render_old
  #   @events_by_month = @events.group_by { |e| [e.starts_at.year, e.starts_at.month] }

  #   define_grid(columns: 3, rows: 1, gutter: 20)
  #   @current_column = 0
  #   @current_year = nil
  #   self.line_width = 1

  #   @events_by_month.each do |year_month, events|
  #     year = year_month[0]
  #     month = year_month[1]

  #     grid(0, @current_column).bounding_box do
  #       month_header = Date::MONTHNAMES[month]

  #       if @current_year.nil? || year != @current_year
  #         month_header = "#{Date::MONTHNAMES[month]} #{year}"
  #         @current_year = year
  #       end

  #       # render month header
  #       move_down 20
  #       font_size 16
  #       formatted_text [
  #         { text: month_header, styles: [:bold], color: COLOR_BRAND, kerning: true }
  #       ]
  #       font_size 10
  #       self.line_width = 1
  #       stroke_horizontal_rule
  #       move_down 10

  #       # iterate over events
  #       self.line_width = 0.5
  #       @presenter = EventPresenter.new
  #       @presenter.plain_text = true
  #       @current_row = 0

  #       events.each_with_index do |event, index|
  #         render_event event
  #       end
  #     end
  #     # render the month's events

  #     @current_column += 1
  #     if @current_column == 3
  #       start_new_page
  #       @current_column = 0
  #     end
  #   end
  # end
