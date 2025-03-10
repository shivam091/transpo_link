# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :product_price do
    association :product
    association :warehouse
    min_quantity { 5 }
    unit_price { 55.0 }
    currency { Money.default_currency.iso_code }
  end
end
