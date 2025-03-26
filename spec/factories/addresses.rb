# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :address do
    address1 { Faker::Address.street_name }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    country { Faker::Address.country_code }
    postal_code { Faker::Address.zip_code }

    trait :for_user do
      association :addressable, factory: :admin
    end

    trait :for_warehouse do
      association :addressable, factory: :warehouse
    end
  end
end
