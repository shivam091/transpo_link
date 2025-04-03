# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :legal_identifier do
    association :user, factory: :buyer
    country { "IN" }
    entity_type { LegalIdentifier.entity_types[:individual] }
    tax_identifier_type { LegalIdentifier.tax_identifier_types[:gstin] }
    tax_identifier { "27AAAFI1234A1Z7" }
    status { LegalIdentifier.statuses[:unapproved] }

    trait :for_business do
      entity_type { LegalIdentifier.entity_types[:business] }
      business_identifier_type { LegalIdentifier.business_identifier_types[:cin] }
      business_identifier { "L12345MH2023PLC000789" }
    end

    trait :approved do
      status { LegalIdentifier.statuses[:approved] }
    end

    trait :rejected do
      status { LegalIdentifier.statuses[:rejected] }
    end
  end
end
