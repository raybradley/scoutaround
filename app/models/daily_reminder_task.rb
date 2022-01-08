# frozen_string_literal: true

# Recurring task to send daily reminders to members
class DailyReminderTask < Task
  attr_accessor :force_run

  def perform
    Rails.logger.warn { "Daily Reminder Sender invoked" }
    Unit.all.includes(:setting_objects).find_each do |unit|
      perform_for_unit(unit)
    end
  end

  # is it time for this unit to run its reminder?
  def time_to_run?(member, current_time)
    return true if force_run
    return true if member.unit.settings(:utilities).fire_scheduled_tasks

    # hardwired to 7:00 AM
    current_time.hour == 7 && current_time.min.zero?
  end

  private

  def perform_for_unit(unit)
    return unless unit.settings(:communication).daily_reminder != "none"
    return unless unit.events.published.imminent.count.positive?

    Rails.logger.warn { "Sending Daily Reminders for #{unit.name}" }

    unit.members.find_each do |member|
      perform_for_member(member)
    end

    unit.settings(:communication).update! daily_reminder_last_sent_at: DateTime.now
  end

  def perform_for_member(member)
    Time.zone = member.unit.settings(:locale).time_zone
    return unless Flipper.enabled? :daily_reminder, member
    return unless time_to_run?(member, Time.zone.now)

    Rails.logger.warn { "Sending Daily Reminder to #{member.flipper_id}" }
    MemberNotifier.new(member).send_daily_reminder
  end
end
