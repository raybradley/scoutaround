# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class PhotoPolicy < UnitContextPolicy
  attr_accessor :photo

  def initialize(membership, photo)
    super
    @membership = membership
    @photo = photo
  end

  def create?
    true
  end

  def new?
    true
  end

  def destroy?
    admin? || @photo.author == current_member
  end

  def show?
    @photo.unit == @membership.unit
  end
end