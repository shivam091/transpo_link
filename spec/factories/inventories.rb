# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory do
    association :product
    association :warehouse
    batch_number { Faker::Alphanumeric.alphanumeric(number: 8).upcase }
    expiration_date { Faker::Date.between(from: Date.current, to: 3.year.from_now) }
    stock_quantity { Faker::Number.between(from: 10, to: 500) }
    reserved_stock { 0 }
    inventory_unit { TranspoLink::MeasurementUnits.units_for(:weight).sample }
    cost_price { stock_quantity * 1.2 }
    currency { Faker::Currency.code }
    tracking_method { Inventory.tracking_methods[:average_cost] }
  end
end
