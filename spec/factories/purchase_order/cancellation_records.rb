# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :po_cancellation_record, class: "PurchaseOrder::CancellationRecord" do
    reason { :other }
    note { Faker::Lorem.sentence(word_count: 50) }
    association :user, factory: :manager

    # Polymorphic associations
    trait :for_po do
      after(:build) do |record|
        record.cancellable = create(:purchase_order, :cancelled)
      end
    end

    trait :for_po_item do
      after(:build) do |record|
        record.cancellable = create(:purchase_order_item, :cancelled)
      end
    end

    factory :po_cancellation, traits: [:for_po]
    factory :po_item_cancellation, traits: [:for_po_item]
  end
end
