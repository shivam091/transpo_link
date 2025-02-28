# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :tax_detail do
    association :user, factory: :admin
    tax_number { "ARTPL8760R" }
    tax_type { "pan" }
    country { "IN" }
  end
end
