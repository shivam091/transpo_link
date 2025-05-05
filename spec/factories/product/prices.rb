# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :product_price, class: "Product::Price" do
    association :product
    association :warehouse
    min_quantity { Faker::Number.between(from: 1, to: 100) }
    unit_price { product.cost_price * 0.8 }
    currency { Faker::Currency.code }
  end
end
