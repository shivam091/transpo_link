# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_batch_stock, class: "InventoryBatch::Stock" do
    association :inventory_batch
    ordered_quantity { 0.0 }
    reserved_quantity { 0.0 }
    damaged_quantity { 0.0 }
    returned_quantity { 0.0 }
    restocked_quantity { 0.0 }
    restockable_quantity { 0.0 }
    available_quantity { 0.0 }
    used_quantity { 0.0 }
    status { InventoryBatch::Stock.statuses[:available] }
    is_locked { false }

    trait :available do
      status { InventoryBatch::Stock.statuses[:available] }
    end

    trait :reserved do
      status { InventoryBatch::Stock.statuses[:reserved] }
    end

    trait :partially_used do
      status { InventoryBatch::Stock.statuses[:partially_used] }
    end

    trait :exhausted do
      status { InventoryBatch::Stock.statuses[:exhausted] }
    end

    trait :locked do
      status { InventoryBatch::Stock.statuses[:locked] }
    end

    trait :damaged do
      status { InventoryBatch::Stock.statuses[:damaged] }
    end

    trait :closed do
      status { InventoryBatch::Stock.statuses[:closed] }
    end

    # Transient attributes
    transient do
      batch_quantity { 1000.0 }  # Set this only when needed
      auto_calculate_quantities { false }
    end

    # Dynamic setup using transient attributes
    before(:create) do |stock, evaluator|
      if evaluator.auto_calculate_quantities
        stock.restocked_quantity = evaluator.restocked_quantity || 30
        stock.used_quantity = evaluator.used_quantity || 20
        stock.restockable_quantity = evaluator.batch_quantity - stock.restocked_quantity
        stock.available_quantity = evaluator.batch_quantity - stock.used_quantity
      end
    end
  end
end
