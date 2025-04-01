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

    PurchaseOrder.statuses.keys.each do |status|
      trait status do
        status { PurchaseOrder.statuses[status] }
      end
    end

    trait :with_po_items do
      after(:create) do |purchase_order|
        create_list(:purchase_order_item, 3, purchase_order: purchase_order)
      end
    end
  end
end
