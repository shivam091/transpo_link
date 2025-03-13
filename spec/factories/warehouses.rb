# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :warehouse do
    name { Faker::Company.name }
    email_address { Faker::Internet.email }
    contact_number { Faker::PhoneNumber.phone_number_with_country_code }
    description { Faker::Company.bs }
    total_capacity { 10**6 } # 1,000,000
    capacity_unit { TranspoLink::MeasurementUnits.units_for(:weight).sample }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }

    trait :small_capacity do
      total_capacity { 10**3 } # 1,000
    end

    trait :large_capacity do
      total_capacity { 10**9 } # 1,000,000,000
    end

    before(:create) do |warehouse|
      warehouse.managers << create(:manager)
      warehouse.suppliers << create(:supplier)
    end
  end
end
