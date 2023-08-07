# methods for dealing with cohorts and recipient lists
module Sendable
  extend ActiveSupport::Concern

  EVENT_REGEXP = /event_(\d+)_attendees/
  TAG_REGEXP = /tag_(\d+)_members/

  # given a list of members, return a list of members and their guardians
  def with_guardians(members)
    parent_relationships = MemberRelationship.where(child_unit_membership_id: members.map(&:id))
    parents = UnitMembership.where(id: parent_relationships.pluck(:parent_unit_membership_id))
    results = members + parents

    # de-dupe it
    results.uniq
  end

  def recipients
    # start building up the scope
    scope = unit.unit_memberships.joins(:user).order(:last_name)
    if object.responds_to? :member_type
      scope = scope.where(member_type: member_type == "youth_and_adults" ? %w[adult youth] : %w[adult]) # adult / youth
    end

    # filter by audience
    if event_cohort?
      event = Event.find($1)
      scope = scope.where(id: event.rsvps.pluck(:unit_membership_id))

    elsif tag_cohort?
      tag = ActsAsTaggableOn::Tag.find($1)
      scope = scope.tagged_with(tag.name)

    else
      scope = scope.where(status: member_status == "active_and_registered" ? %w[active registered] : %w[active])
    end

    results = with_guardians(scope.all)
    results.select(&:emailable?)
  end

  def event_cohort?
    audience =~ EVENT_REGEXP
  end

  def tag_cohort?
    audience =~ TAG_REGEXP
  end
end
