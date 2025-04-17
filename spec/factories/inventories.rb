# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory do
    association :product
    association :warehouse
    unit { find_or_create_unit("item") }
    currency { Faker::Currency.code }
    low_stock_threshold { 10 }

    trait :fifo do
      tracking_method { Inventory.tracking_methods[:fifo] }
    end

    trait :lifo do
      tracking_method { Inventory.tracking_methods[:lifo] }
    end

    trait :average_cost do
      tracking_method { Inventory.tracking_methods[:average_cost] }
    end
  end
end
