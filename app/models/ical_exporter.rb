# frozen_string_literal: true

require "icalendar"

# given an Event object, render an Icalendar record
class IcalExporter
  attr_accessor :event, :tzid

  def initialize(member, event = nil)
    @member = member
    self.event = event
  end

  # rubocop:disable Metrics/AbcSize
  def to_ical
    ical_event = Icalendar::Event.new
    ical_event.summary = ical_summary
    if @event.all_day?
      ical_event.dtstart = Icalendar::Values::DateOrDateTime.new(@event.starts_at.to_date, tzid: "UTC")
      ical_event.dtend = Icalendar::Values::DateOrDateTime.new(@event.ends_at.to_date, tzid: "UTC")
    else
      ical_event.dtstart = Icalendar::Values::DateOrDateTime.new(@event.starts_at.utc, tzid: "UTC")
      ical_event.dtend = Icalendar::Values::DateOrDateTime.new(@event.ends_at.utc, tzid: "UTC")
    end
    ical_event.location = @event.online ? @event.website : @event.full_address
    ical_event.description = @event.description&.to_plain_text || @event.short_description
    ical_event.url = Rails.application.routes.url_helpers.unit_event_url(
      @event.unit, @event, host: ENV.fetch("APP_HOST")
    )
    add_alarms(ical_event)

    ical_event
  end
  # rubocop:enable Metrics/AbcSize

  def self.ics_attachment(event, member)
    {
      mime_type:           "multipart/mixed",
      content_type:        "text/calendar; method=REQUEST; charset=UTF-8; component=VEVENT",
      content_disposition: "attachment; filename=#{event.ical_filename}",
      content:             event.to_ical(member)
    }
  end

  private

  def ical_summary
    res = "#{@event.unit.short_name} - #{@event.title}"
    res += " (DRAFT)" if @event.draft?
    res += " (CANCELLED)" if @event.cancelled?
    res
  end

  def add_alarms(ical_event)
    ical_event.alarm do |a|
      a.action = "DISPLAY"
      a.description = ical_event.summary
      a.summary = ical_event.summary
      a.trigger = "-PT1H" # 1 hour before
    end
  end
end
