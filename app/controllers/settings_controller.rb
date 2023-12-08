# frozen_string_literal: true

# this has been superceded by the UnitsController + UnitTaskService

class SettingsController < UnitContextController
  TASK_KEY_RSVP_NAG = "rsvp_nag"
  TASK_DAY_RSVP_NAG = 2 # Tuesday
  TASK_HOUR_RSVP_NAG = 10 # 10 AM local

  before_action :find_unit

  # GET /units/:unit_id/settings
  def edit
    @page_title = [@unit.name, "Settings"]
    authorize @unit, policy_class: UnitSettingsPolicy
  end

  def index
    authorize @unit, :edit?
  end

  # POST /unit/:unit_id/settings
  def update
    @unit.update(unit_params) if params[:unit].present?
    @unit.settings(:utilities).fire_scheduled_tasks = true if params.dig(:settings, :utilities, :fire_scheduled_tasks)
    @unit.settings(:locale).meeting_location = params.dig(:settings, :locale, :meeting_location)
    @unit.settings(:locale).meeting_address = params.dig(:settings, :locale, :meeting_address)
    @unit.settings(:communication).rsvp_nag = params.dig(:settings, :communication, :rsvp_nag)

    set_schedule

    @unit.save!
    redirect_to unit_settings_path(@unit)
  end

  def pundit_user
    @current_member
  end

  def difference_in_days(from, to)
    (to.to_date - from.to_date).to_i
  end

  private

  # handle scheduled task serialization
  def set_schedule
    Time.zone = @unit.settings(:locale).time_zone
    set_digest_schedule
    set_reminder_schedule
    set_rsvp_nag_schedule
  end

  def set_rsvp_nag_schedule
    @unit.tasks.where(key: TASK_KEY_RSVP_NAG).destroy_all
    return unless params.dig(:settings, :communication, :rsvp_nag) == "true"

    task = @unit.tasks.create(key: TASK_KEY_RSVP_NAG, type: "RsvpNagTask")
    rule = IceCube::Rule.weekly.day(TASK_DAY_RSVP_NAG).hour_of_day(TASK_HOUR_RSVP_NAG)
    task.schedule.start_time = DateTime.now.in_time_zone
    task.schedule.add_recurrence_rule rule
    task.save_schedule
  end

  def set_digest_schedule
    digest_setting = params.dig(:settings, :communication, :digest)
    @unit.settings(:communication).update!(digest: digest_setting)
    return unless @unit.settings(:communication).digest == "true"

    SendWeeklyDigestJob.schedule_next_job(@unit)
  end

  def set_digest_schedule_old
    digest_schedule_params = params.dig(:settings, :communication, :digest_schedul)
    return unless digest_schedule_params

    day_of_week = digest_schedule_params[:day_of_week].to_i
    hour_of_day = digest_schedule_params[:hour_of_day].to_i
    digest_task = @unit.tasks.find_or_create_by(key: "digest", type: "UnitDigestTask")
    rule = IceCube::Rule.weekly.day(day_of_week).hour_of_day(hour_of_day).minute_of_hour(0)

    digest_task.clear_schedule
    digest_task.schedule.start_time = DateTime.now.in_time_zone # this should put IceCube into the unit's local time zone
    digest_task.schedule.add_recurrence_rule rule
    digest_task.schedule.add_recurrence_rule IceCube::Rule.minutely(60) if digest_schedule_params[:every_hour] == "yes"

    digest_task.save_schedule
  end

  def set_reminder_schedule
    reminder_enabled = params.dig(:settings, :communication, :daily_reminder) == "yes"
    reminder_task = @unit.tasks.find_or_create_by(key: "daily_reminder", type: "DailyReminderTask")

    if reminder_enabled
      rule = IceCube::Rule.daily.hour_of_day(7).minute_of_hour(0)
      reminder_task.clear_schedule
      reminder_task.schedule.start_time = DateTime.now.in_time_zone # this should put IceCube into the unit's local time zone
      reminder_task.schedule.add_recurrence_rule rule
      reminder_task.save_schedule
    else
      reminder_task.destroy
    end
  end

  def find_unit
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
    Time.zone = @unit.settings(:locale).time_zone
  end

  def unit_params
    params.require(:unit).permit(
      :name,
      :location,
      :logo,
      :slug,
      :allow_youth_rsvps,
      settings: [
        [communication: [:rsvp_nag, { digest_schedule: [:day_of_week, :hour_of_day, :every_hour] }]],
        :utilities
      ]
    )
  end
end

# IceCube::Schedule.new.add_recurrence_rule(IceCube::Rule.weekly.day(0).hour_of_day(7).minute_of_hour(0))
