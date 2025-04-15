# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    sku { Faker::Alphanumeric.alphanumeric(number: 12).upcase }
    barcode { Faker::Barcode.ean }
    currency { Faker::Currency.code }
    cost_price { Faker::Commerce.price(range: 5.0..1000.0) }
    association :product_category
    unit { find_or_create_unit("item") }
  end
end
