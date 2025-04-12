# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_batch do
    association :inventory
    batch_number { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    expiration_date { Faker::Date.between(from: 1.year.from_now, to: 3.years.from_now) }
    quantity { Faker::Number.between(from: 10, to: 500) }
    association :unit, factory: :dozen_unit
    currency { Faker::Currency.code }
    cost_price { Faker::Commerce.price(range: 5.0..1000.0) }
  end
end
