# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :stock do
    association :inventory
    quantity_in_hand { 0.0 }
    quantity_pending_to_buyer { 0.0 }
  end
end
