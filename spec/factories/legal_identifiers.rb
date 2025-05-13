# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :legal_identifier do
    association :user, factory: :buyer
    country { "IN" }
    entity_type { :individual }
    tax_identifier_type { :gstin }
    tax_identifier { "27AAAFI1234A1Z7" }

    trait :for_business do
      entity_type { :business }
      business_identifier_type { :cin }
      business_identifier { "L12345MH2023PLC000789" }
    end

    trait :unapproved do
      status { :unapproved }
    end

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end

    LegalIdentifier.tax_identifier_types.each_key do |tax_identifier_type|
      trait "ti_#{tax_identifier_type}" do
        tax_identifier_type { tax_identifier_type }
      end
    end

    LegalIdentifier.business_identifier_types.each_key do |business_identifier_type|
      trait "bi_#{business_identifier_type}" do
        business_identifier_type { business_identifier_type }
      end
    end
  end
end
