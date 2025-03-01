# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :tax_rate do
    country { "IN" }
    tax_type { "gstin" }
    rate { 8.0 }
    valid_from { Date.current }
    valid_to { Date.current + 1.year }
  end
end
