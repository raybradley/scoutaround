# frozen_string_literal: true

# notify users under different scenarios
class EventNotifier
  include Sidekiq::Job

  def rsvp_opening(user); end

  # this gets called by Sidekiq
  def perform(event_id, member_id, note = nil)
    @event = Event.find(event_id)
    member = UnitMembership.find(member_id)
    send_cancellation(member, note)
  end

  # this gets called when instantiating the class directly
  def initialize(event = nil)
    @event = event
  end

  def send_cancellation(member, note = nil)
    return unless member.contactable?

    EventMailer.with(event: @event, member: member, note: note).cancellation_email.deliver_later
  end

  def self.after_publish(event)
    return unless event.requires_rsvp

    event.unit.members.status_active.each do |member|
      next unless member.contactable?
      next unless Flipper.enabled? :receive_event_publish_notice, member

      token = event.rsvp_tokens.find_or_create_by!(unit_membership: member)
      EventMailer.with(token: token, member: token.member).token_invitation_email.deliver_later
    end
  end

  def self.after_bulk_publish(unit, events)
    unit.members.status_active.each do |member|
      next unless Flipper.enabled? :receive_bulk_publish_notice, member

      user = member.user
      EventMailer.with(unit: unit, user: user, event_ids: events.map(&:id), member: member).bulk_publish_email.deliver_later
    end
  end

  def self.invite_member_to_event(token)
    EventMailer.with(token: token, member: token.member).token_invitation_email.deliver_later
  end

  def self.send_rsvp_confirmation(rsvp)
    return unless rsvp.contactable?
    return unless Flipper.enabled? :receive_rsvp_confirmation, rsvp.unit_membership


    EventMailer.with(rsvp: rsvp, member: rsvp.unit_membership).rsvp_confirmation_email.deliver_later
  end
end
