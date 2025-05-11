# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_batch_stock, class: "InventoryBatch::Stock" do
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
  end
end
