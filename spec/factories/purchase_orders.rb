# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :purchase_order do
    association :warehouse
    association :supplier
    association :manager
    reference_document { Faker::Alphanumeric.alphanumeric(number: 12).upcase }
    order_date { Date.current }
    expected_delivery_date { order_date + 1.month }
    notes { Faker::Lorem.paragraph(sentence_count: 3) }
    status { PurchaseOrder.statuses[:draft] }

    trait :draft do
      status { PurchaseOrder.statuses[:draft] }
    end

    trait :submitted do
      status { PurchaseOrder.statuses[:submitted] }
    end

    trait :approved do
      status { PurchaseOrder.statuses[:approved] }
    end

    trait :partially_delivered do
      status { PurchaseOrder.statuses[:partially_delivered] }
    end

    trait :fully_delivered do
      status { PurchaseOrder.statuses[:fully_delivered] }
    end

    trait :cancelled do
      status { PurchaseOrder.statuses[:cancelled] }
    end

    trait :rejected do
      status { PurchaseOrder.statuses[:rejected] }
    end

    trait :closed do
      status { PurchaseOrder.statuses[:closed] }
    end

    trait :on_hold do
      status { PurchaseOrder.statuses[:on_hold] }
    end

    trait :with_po_items do
      transient do
        items_count { 2 }
      end

      after(:create) do |purchase_order, evaluator|
        create_list(:purchase_order_item, evaluator.items_count, purchase_order:)
      end
    end
  end
end
