# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :legal_identifier do
    association :user, factory: :buyer
    entity_type { "individual" }
    tax_identifier_type { "gstin" }
    tax_identifier { "27AAAFI1234A1Z7" }
    country { "IN" }

    trait :for_business do
      entity_type { "business" }
      business_identifier_type { "cin" }
      business_identifier { "L12345MH2025LLP67890" }
    end
  end
end
