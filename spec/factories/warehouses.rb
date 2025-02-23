# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :warehouse do
    name { "TranspoLink Logistics" }
    email_address
    contact_number
    description { "Description of TranspoLink Logistics" }
    total_capacity { 10**8 } # 100,000,000 lb
    capacity_unit { "lb" }
    latitude { 19.2578818 }
    longitude { 73.144015 }

    trait :small_capacity do
      total_capacity { 10**5 } # 100,000 lb
    end

    trait :medium_capacity do
      total_capacity { 10**6 } # 1,000,000 lb
    end

    trait :large_capacity do
      total_capacity { 10**9 } # 1,000,000,000 lb
    end
  end
end
