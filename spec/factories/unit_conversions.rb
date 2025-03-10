# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :unit_conversion do
    association :product
    from_unit { "item" }
    to_unit { "pack" }
    conversion_rate { 12.0 }
  end
end
