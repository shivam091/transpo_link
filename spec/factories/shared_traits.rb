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

  LegalIdentifier.tax_identifier_types.values.each do |tax_identifier_type|
    trait "ti_#{tax_identifier_type}" do
      tax_identifier_type { tax_identifier_type }
    end
  end

  LegalIdentifier.business_identifier_types.values.each do |business_identifier_type|
    trait "bi_#{business_identifier_type}" do
      business_identifier_type { business_identifier_type }
    end
  end
end
