# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :purchase_order_item, class: "PurchaseOrder::Item" do
    # unit_cost & currency will be set automatically from Product#cost_price & Product#currency, respectively.
    association :purchase_order
    association :product
    quantity { Faker::Number.between(from: 1, to: 100) }
    unit { find_or_create_unit("item") }
    status { PurchaseOrder::Item.statuses[:pending] }

    trait :pending do
      status { PurchaseOrder::Item.statuses[:pending] }
    end

    trait :ordered do
      status { PurchaseOrder::Item.statuses[:ordered] }
    end

    trait :partially_delivered do
      status { PurchaseOrder::Item.statuses[:partially_delivered] }
    end

    trait :delivered do
      status { PurchaseOrder::Item.statuses[:delivered] }
    end

    trait :cancelled do
      status { PurchaseOrder::Item.statuses[:cancelled] }
    end
  end
end
