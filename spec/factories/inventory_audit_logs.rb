# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_audit_log do
    association :inventory
    association :inventory_movement
    association :user, factory: :manager
    movement_type { "restock" }
    previous_quantity { 80 }
    new_quantity { 100 }
    metadata { {} }
  end
end
