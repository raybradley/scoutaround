# frozen_string_literal: true

# job to send reminder to unit members
class EventReminderJob < ApplicationJob
  include Sendable
  REMINDER_INTERVAL = 12.hours

  queue_as :default

  def perform(event_id, event_updated_at)
    @event = Event.find(event_id)

    return unless Flipper.enabled? :event_reminder_jobs, @event.unit
    return unless @event.updated_at == event_updated_at # see https://stackoverflow.com/questions/53373100/rails-5-delete-an-activejob-before-it-gets-performed

    remind!
  end

  private

  def remind!
    return unless published? # belt & suspenders
    return if ended?

    EventReminderNotification.with(
      event: @event,
      message: sms_message
    ).deliver_later(@event.notification_recipients)
  end

  def sms_message
    renderer.render(
      template: "member_texter/daily_reminder",
      format: "text",
      assigns: { event: @event, unit: @event.unit }
    )
  end
end
