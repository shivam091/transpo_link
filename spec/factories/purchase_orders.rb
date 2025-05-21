# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :purchase_order do
    association :warehouse
    association :supplier
    association :manager
    order_date { Date.current }
    notes { Faker::Lorem.paragraph(sentence_count: 3) }
    status { :draft }

    trait :draft do
      status { :draft }
    end

    trait :submitted do
      status { :submitted }
    end

    trait :approved do
      status { :approved }
    end

    trait :shipped do
      status { :shipped }
    end

    trait :partially_delivered do
      status { :partially_delivered }
    end

    trait :fully_delivered do
      status { :fully_delivered }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :closed do
      status { :closed }
    end

    trait :on_hold do
      status { :on_hold }
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
