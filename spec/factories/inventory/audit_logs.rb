# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_audit_log, class: "Inventory::AuditLog" do
    association :inventory
    association :movement, factory: :inventory_movement
    association :user, factory: :manager
    type { Inventory::Movement.types.keys.sample }
    previous_quantity { Faker::Number.between(from: 1, to: 100) }
    new_quantity { Faker::Number.between(from: 1, to: 100) }
    metadata { {type:, previous_quantity:, new_quantity:} }
  end
end
