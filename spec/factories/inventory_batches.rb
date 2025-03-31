# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_batch do
    association :inventory
    batch_number { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    expiration_date { Faker::Date.between(from: 1.year.from_now, to: 3.years.from_now) }
    quantity { Faker::Number.between(from: 10, to: 500) }
    inventory_unit { TranspoLink::MeasurementUnits.units_for(:weight).sample }
    currency { Faker::Currency.code }
  end
end
