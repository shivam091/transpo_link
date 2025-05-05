# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_movement, class: "Inventory::Movement" do
    association :inventory
    quantity { Faker::Number.between(from: 1, to: 100) }
    type { Inventory::Movement.types[:restock] }
    association :unit, factory: :dozen_unit
    unit_cost { Faker::Commerce.price(range: 2.0..500.0)  }
    total_cost { quantity * unit_cost.to_f }
    currency { Faker::Currency.code }
    movement_date { Faker::Date.backward(days: 14) }
    metadata { {type:} }
    association :source, factory: :inventory

    trait :restock do
      type { Inventory::Movement.types[:restock] }
    end

    trait :purchase do
      type { Inventory::Movement.types[:purchase] }
    end
  end
end
