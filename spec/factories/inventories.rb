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
    tracking_method { :average_cost }

    trait :fifo do
      tracking_method { :fifo }
    end

    trait :lifo do
      tracking_method { :lifo }
    end

    trait :average_cost do
      tracking_method { :average_cost }
    end

    trait :with_quantity_in_hand do
      transient do
        quantity { 0 }
      end

      after(:create) do |inventory, evaluator|
        inventory.stock.update!(quantity_in_hand: evaluator.quantity)
      end
    end

    trait :with_quantity_pending_to_buyer do
      transient do
        quantity { 0 }
      end

      after(:create) do |inventory, evaluator|
        inventory.stock.update!(quantity_pending_to_buyer: evaluator.quantity)
      end
    end

    trait :with_quantity_pending_from_supplier do
      transient do
        quantity { 0 }
      end

      after(:create) do |inventory, evaluator|
        inventory.replenishment.update!(
          quantity_pending_from_supplier: evaluator.quantity
        )
      end
    end

    trait :with_stock_quantities do
      transient do
        quantity_in_hand { 0 }
        quantity_pending_to_buyer { 0 }
      end

      after(:create) do |inventory, evaluator|
        inventory.stock.update!(
          quantity_in_hand: evaluator.quantity_in_hand,
          quantity_pending_to_buyer: evaluator.quantity_pending_to_buyer
        )
      end
    end
  end
end
