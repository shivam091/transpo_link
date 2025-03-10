# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :feedback do
    association :user, factory: :buyer
    # Polymorphic association: Can be Order, Product, Shipment, or Driver
    association :reviewable, factory: :product
    is_unread { true } # Defaults to unread for tracking new feedbacks
    rating { (0..10).step(0.5).to_a.sample } # Ensures valid step values
    comment { Faker::Lorem.sentence(word_count: 20) }

    trait :read do
      is_unread { false }
    end

    trait :with_high_rating do
      rating { (8..10).step(0.5).to_a.sample }
    end

    trait :with_low_rating do
      rating { (0..2).step(0.5).to_a.sample }
    end

    trait :for_product do
      association :reviewable, factory: :product
    end
  end
end
