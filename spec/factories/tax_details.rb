# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :tax_detail do
    association :user, factory: :buyer
    entity_type { "individual" }
    tax_type { "gstin" }
    tax_number { "27ABCDE1234B1Z5" }
    country { "IN" }

    trait :for_business do
      entity_type { "business" }
      business_number_type { "cin" }
      business_number { "L12345MH2025LLP67890" }
    end
  end
end
