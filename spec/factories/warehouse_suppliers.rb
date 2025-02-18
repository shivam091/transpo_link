# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :warehouse_supplier do
    association :warehouse
    supplier { create(:supplier, :confirmed) }
  end
end
