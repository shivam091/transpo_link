# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :purchase_order_item do
    # unit_cost & currency will be set automatically from Product#cost_price & Product#currency, respectively.
    association :purchase_order
    association :product
    quantity { 1000 }
    unit { find_or_create_unit("item") }
    status { PurchaseOrderItem.statuses[:pending] }
    received_quantity { 0 }

    trait :pending do
      status { PurchaseOrderItem.statuses[:pending] }
    end

    trait :ordered do
      status { PurchaseOrderItem.statuses[:ordered] }
    end

    trait :partially_delivered do
      received_quantity { 500 }
      status { PurchaseOrderItem.statuses[:partially_delivered] }
    end

    trait :delivered do
      received_quantity { 1000 }
      status { PurchaseOrderItem.statuses[:delivered] }
    end

    trait :cancelled do
      status { PurchaseOrderItem.statuses[:cancelled] }
    end

    trait :with_deliveries do
      transient do
        deliveries_count { 2 }
      end

      after(:create) do |purchase_order_item, evaluator|
        create_list(
          :po_item_delivery,
          evaluator.deliveries_count,
          quantity: purchase_order_item.quantity / evaluator.deliveries_count,
          unit: purchase_order_item.unit,
          purchase_order_item:
        )
      end
    end
  end
end
