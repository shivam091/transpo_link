# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_batch do
    association :inventory
    batch_number { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    lot_number { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    manufactured_at { Date.current - 1.month }
    expiration_date { Faker::Date.between(from: 1.year.from_now, to: 3.years.from_now) }
    received_at { Date.current + 1.month }
    quantity { 10 }
    unit { find_or_create_unit("item") }
    currency { Faker::Currency.code }
    cost_price { Faker::Commerce.price(range: 5.0..1000.0) }
    location { "Bin 1" }
    notes { Faker::Lorem.sentence(word_count: 50) }
    association :source, factory: :purchase_order_item
  end
end
