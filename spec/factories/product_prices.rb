# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :product_price do
    association :product
    association :warehouse
    min_quantity { Faker::Number.between(from: 1, to: 100) }
    unit { find_or_create_unit("item") }
    unit_price { 150.0 }
    currency { Faker::Currency.code }
    effective_period { Date.current..(Date.current + 1.month) }

    trait :with_virtual_attributes do
      transient do
        effective_from { Date.current }
        effective_until { Date.current + 1.month }
      end
    end
  end
end
