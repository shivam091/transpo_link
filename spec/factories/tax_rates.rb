# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :tax_rate do
    country { "IN" }
    tax_identifier_type { "gstin" }
    business_category { "b2b" }
    rate { 12.0 }
    valid_from { Date.current }
    valid_to { Date.current + 1.month }
  end

  trait :for_b2c do
    business_category { "b2c" }
  end
end
