class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :event_rsvps, dependent: :destroy
  has_many :unit_memberships, dependent: :destroy
  has_many :parent_relationships, foreign_key: 'child_id', class_name: 'UserRelationship', dependent: :destroy
  has_many :child_relationships, foreign_key: 'parent_id', class_name: 'UserRelationship', dependent: :destroy
  has_many :rsvp_tokens, dependent: :destroy

  accepts_nested_attributes_for :event_rsvps

  def full_name
    "#{first_name} #{last_name}"
  end

  def parents
    parent_relationships.map(&:parent)
  end

  def children
    child_relationships.map(&:child)
  end

  def family
    children.append(self)
  end
end
