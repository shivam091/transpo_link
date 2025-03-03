# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :tax_detail do
    association :user, factory: :buyer
    tax_number { "27ABCDE1234B1Z5" }
    tax_type { "gstin" }
    country { "IN" }
  end
end
