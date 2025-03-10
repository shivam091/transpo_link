# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory do
    association :product
    association :warehouse
    batch_number { Faker::Alphanumeric.alphanumeric(number: 8).upcase }
    expiration_date { Faker::Date.between(from: Date.current, to: 3.year.from_now) }
    stock_quantity { 100 }
    reserved_stock { 10 }
    inventory_unit { "kg" }
    cost_price { 48.0 }
    currency { Money.default_currency.iso_code }
  end
end
