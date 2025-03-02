# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :tax_rate do
    country { "DE" }
    tax_type { "vat" }
    rate { 8.0 }
    valid_from { Date.current }
    valid_to { Date.current + 1.year }
  end

  trait :for_b2b do
    business_category { "b2b" }
  end

  trait :for_b2c do
    business_category { "b2c" }
  end
end
