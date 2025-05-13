# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    sku { Faker::Alphanumeric.alphanumeric(number: 12).upcase }
    barcode { Faker::Barcode.ean }
    currency { Faker::Currency.code }
    cost_price { Faker::Commerce.price(range: 5.0..1000.0) }
    association :product_category
    unit { find_or_create_unit("item") }

    trait :with_price_tiers do
      transient do
        warehouse { create(:warehouse) }
        tiers do
          [
            {min_quantity: 1, unit_price: 200.0},
            {min_quantity: 10, unit_price: 180.0},
            {min_quantity: 50, unit_price: 160.0}
          ]
        end
      end

      after(:create) do |product, evaluator|
        evaluator.tiers.each do |tier|
          create(:product_price,
            product: product,
            warehouse: evaluator.warehouse,
            unit: product.unit,
            currency: product.currency,
            effective_from: Date.current,
            effective_until: Date.current + 1.month,
            **tier
          )
        end
      end
    end

  end
end
