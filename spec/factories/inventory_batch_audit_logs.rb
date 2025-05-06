# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :inventory_batch_audit_log do
    association :inventory_batch
    association :user, factory: :manager
    previous_quantity { Faker::Number.between(from: 1, to: 100) }
    new_quantity { Faker::Number.between(from: 1, to: 100) }
    metadata { {previous_quantity:, new_quantity:} }
  end
end
