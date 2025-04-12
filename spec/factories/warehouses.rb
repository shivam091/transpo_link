# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :warehouse do
    name { Faker::Company.name }
    email_address { Faker::Internet.email }
    contact_number { Faker::PhoneNumber.phone_number_with_country_code }
    description { Faker::Company.bs }
    total_capacity { 1000000.0 }
    association :unit, factory: :item_unit
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }

    trait :small_capacity do
      total_capacity { 1000.0 }
    end

    trait :large_capacity do
      total_capacity { 1000000000000.0 }
    end

    before(:create) do |warehouse|
      warehouse.managers << create(:manager)
      warehouse.suppliers << create(:supplier)
    end
  end
end
