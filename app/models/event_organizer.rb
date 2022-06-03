class EventOrganizer < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership
  has_one :user, through: :unit_membership
  enum role: { organizer: "organizer", money: "money" }
  alias_attribute :member, :unit_membership
  delegate :full_display_name, to: :user
end
