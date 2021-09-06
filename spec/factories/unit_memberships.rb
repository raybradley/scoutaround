FactoryBot.define do
  factory :unit_membership do
    unit
    user
    status { 'active' }
    role   { 'member' }

    trait :admin do
      role { 'admin' }
    end
  end
end
