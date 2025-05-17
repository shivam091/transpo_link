# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :tax_rate do
    country { "IN" }
    tax_identifier_type { :gstin }
    rate { 12.0 }
    valid_from { Date.current }
    valid_to { Date.current + 1.month }
  end

  trait :inclusive do
    tax_type { :inclusive }
  end

  trait :b2c do
    business_category { :b2c }
  end
end
