require "rails_helper"

RSpec.describe AddressBook, type: :model do
  it "works" do
    unit = FactoryBot.create(:unit)
    10.times.each do
      FactoryBot.create(:unit_membership, unit: unit)
    end
    address_book = AddressBook.new(unit)
    expect(address_book.entries).to be_a(Array)
    expect(address_book.entries.count).to eq(unit.unit_memberships.count + 3)
  end

  it "works with events" do
    rsvp = FactoryBot.create(:event_rsvp, :accepted)
    event = rsvp.event
    unit = event.unit
    address_book = AddressBook.new(unit)
    expect(address_book.entries).to be_a(Array)
    expect(address_book.entries.count).to eq(1)
  end
end
