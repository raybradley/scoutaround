# frozen_string_literal: true

# Recurring task to send daily reminders to event organizers
# containing all RSVPs, flagging those that are new within
# the last 24 hours.
class EventOrganizerDigestTask < UnitTask
  def description
    "Daily digest for event organizers"
  end

  def perform
    Time.zone = unit.settings(:locale).time_zone
    unit.members.each do |member|
      next unless member.receives_event_rsvps?

      notifier = MemberNotifier.new(member)
      notifier.send_event_organizer_digest(last_ran_at)
    end
    super
  end

  def setup_schedule
    return if schedule_hash.present?

    evening_rule = IceCube::Rule.daily.hour_of_day(19).minute_of_hour(0)
    schedule.start_time = DateTime.now.in_time_zone
    schedule.add_recurrence_rule evening_rule

    save_schedule
  end
end
