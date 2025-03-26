# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_audit_log do
    association :inventory
    association :inventory_movement
    association :user, factory: :manager
    movement_type { InventoryMovement.movement_types.keys.sample }
    previous_quantity { Faker::Number.between(from: 1, to: 100) }
    new_quantity { Faker::Number.between(from: 1, to: 100) }
    metadata { {movement_type:, previous_quantity:, new_quantity:} }
  end
end
