# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_movement do
    association :inventory
    quantity { 20 }
    movement_type { "restock" }
    inventory_unit { "kg" }
    unit_cost { 50.0 }
    total_cost { 1000.0 }
    currency { Money.default_currency.iso_code }
    movement_date { Time.current }
    association :source, factory: :product
  end
end
