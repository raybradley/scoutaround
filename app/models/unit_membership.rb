# frozen_string_literal: true

# A join model between Units and Users. In fact, the bulk of the
# business logic in the app is based on a UnitMembership rather than
# a User. The User model is really more for authentication and
# basic user demographic information (e.g. DOB) that's unlikely to change
# from one Unit to another
#
#
# rubocop:disable Metrics/ClassLength
class UnitMembership < ApplicationRecord
  ROLES = %w[member admin event_organizer].freeze

  after_initialize :set_defaults, unless: :persisted?

  include Flipper::Identifier
  include Contactable

  belongs_to :unit
  belongs_to :user, touch: true

  validates_uniqueness_of :user, scope: :unit
  validates_presence_of :user, :status
  validates_uniqueness_of :token, allow_nil: true

  has_many  :parent_relationships,
            foreign_key: "child_unit_membership_id",
            class_name:  "MemberRelationship",
            inverse_of:  :child_unit_membership

  has_many  :child_relationships,
            foreign_key: "parent_unit_membership_id",
            class_name:  "MemberRelationship",
            inverse_of:  :parent_unit_membership,
            dependent:   :destroy

  has_many :parents, through: :parent_relationships, source: :parent_unit_membership
  has_many :children, through: :child_relationships, source: :child_unit_membership

  has_many :rsvp_tokens, dependent: :destroy
  has_many :event_rsvps, dependent: :destroy
  has_many :magic_links, dependent: :destroy
  has_many :messages, foreign_key: :author_id
  has_many :visits, class_name: "Ahoy::Visit"
  has_many :event_organizers
  has_many :organized_events, through: :event_organizers, source: :event
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :payments, dependent: :destroy
  has_secure_token

  alias_method :rsvps, :event_rsvps

  enum status: { inactive: 0, active: 1, registered: 2 }, _prefix: true
  enum role: ROLES.zip(ROLES).to_h
  enum member_type: { unknown: 0, youth: 1, adult: 2 }

  scope :active, -> { where(status: %i[active]) }
  scope :registered, -> { where(status: %i[registered]) }
  scope :status_active_and_registered, -> { where(status: %i[active registered]) } # everyone except inactives
  scope :contactable, -> { joins(:user).where("email NOT LIKE 'anonymous-member-%@scoutplan.org'") }
  scope :emailable, -> { joins(:user).where("email NOT LIKE 'anonymous-member-%@scoutplan.org'") }
  scope :message_approver, -> { where(role: %i[admin]) }

  delegate :time_zone, to: :unit
  delegate :name, to: :unit, prefix: :unit
  delegate_missing_to :user

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :child_relationships, allow_destroy: true
  accepts_nested_attributes_for :parent_relationships, allow_destroy: true

  has_settings do |s|
    s.key :security, defaults: { enable_magic_links: true }
    s.key :communication, defaults: {
      via_email:                  true,
      via_sms:                    true,
      event_organizer_digest:     true,
      receives_event_invitations: false,
      receives_all_rsvps:         false
    }
    s.key :alerts
  end

  acts_as_taggable_on :tags
  acts_as_taggable_tenant :unit_id

  def child_of?(candidate)
    return parents.include?(candidate) if candidate.is_a?(UnitMembership)

    parents.map(&:user).include?(candidate) if candidate.is_a?(User)
  end

  def siblings
    parents.includes(:children).flat_map(&:children) - [self]
  end

  def display_first_name(member = nil)
    return "you" if member == self

    user.display_first_name
  end

  #
  # returns the member's family, including self if desired
  # member.family(include_self: true)     => [parent1, parent2, child1, child2, member]
  # member.family                         => [parent1, parent2, child1, child2, member]  (same as true)
  # member.family(include_self: :append)  => [parent1, parent2, child1, child2] (same as true)
  # member.family(include_self: :prepend) => [member, parent1, parent2, child1, child2]
  #
  def family(include_self: :append)
    res = (children | parents | siblings).uniq
    res.append(self) if [true, :append].include?(include_self)
    res.unshift(self) if include_self == :prepend
    res
  end

  def family_name
    family.map(&:last_name).uniq.join(" / ")
  end

  def contactable_object
    self
  end

  def receives_event_rsvps?
    settings(:communication).receives_all_rsvps || event_organizers.any?
  end

  def set_defaults
    self.role = "member"
    self.status = "active"
    self.member_type = "youth"
  end

  def smsable?
    user.smsable? && settings(:communication).via_sms
  end

  def disable_delivery!(method: nil)
    return unless method

    settings(:communication).update!(via_email: false) if method == :email
  end

  def time_zone
    @time_zone ||= user.settings(:locale).time_zone ||
                   unit.settings(:locale).time_zone ||
                   Rails.configuration.default_time_zone
  end

  def sender_name_and_address
    "#{user.display_name} at #{unit.name} <#{unit.from_address}>"
  end
end
# rubocop:enable Metrics/ClassLength
