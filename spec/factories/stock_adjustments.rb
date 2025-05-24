# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :stock_adjustment do
    association :inventory_batch
    association :user
    adjustment_reason { :stock_count_discrepancy }
    adjusted_quantity { 10.0 }
    note { "Adjusted due to manual count verification" }
  end
end
