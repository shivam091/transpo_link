# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :unit_conversion do
    association :product
    from_unit { "kg" }
    to_unit { "g" }
    conversion_rate { 1000 }
  end
end
