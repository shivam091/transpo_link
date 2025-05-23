# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :stock_adjustment do
    association :inventory
    adjusted_quantity { 10.0 }
    adjustment_type { :increase }
    adjustment_reason { :stock_count_discrepancy }
    note { "Adjusted due to manual count verification" }
    association :user
    association :adjustable, factory: :inventory_batch # or :inventory if adjusting inventory level

    trait :negative_adjustment do
      adjustable_type { :decrease }
    end
  end
end
