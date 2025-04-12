# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory do
    association :product
    association :warehouse
    association :unit, factory: :dozen_unit
    tracking_method { Inventory.tracking_methods[:average_cost] }
    currency { Faker::Currency.code }
    low_stock_threshold { 10 }
  end
end
