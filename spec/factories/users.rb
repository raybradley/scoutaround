# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}_#{Time.now.to_f}@example.com"
  end

  factory :user do
    first_name  { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    phone       { Faker::PhoneNumber.cell_phone }
    password    { "password" }
    email
    type { 0 }
  end

  factory :adult, parent: :user, aliases: [:parent]
  factory :youth, parent: :user, aliases: [:child]
end
