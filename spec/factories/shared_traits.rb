# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  trait :active do
    is_active { true }
  end

  trait :with_address do
    after(:create) do |object|
      create(:address, addressable: object)
    end
  end

  TaxRate.tax_identifier_types.keys.each do |tax_identifier_type|
    trait tax_identifier_type do
      tax_identifier_type { tax_identifier_type.to_s }
    end
  end
end
