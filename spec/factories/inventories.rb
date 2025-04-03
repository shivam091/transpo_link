# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory do
    association :product
    association :warehouse
    tracking_method { Inventory.tracking_methods[:average_cost] }
    inventory_unit { TranspoLink::MeasurementUnits.units_for(:weight).sample }
    currency { Faker::Currency.code }
    low_stock_threshold { 10 }
  end
end
