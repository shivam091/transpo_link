# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :tax_rate do
    country { "IN" }
    tax_identifier_type { LegalIdentifier.tax_identifier_types[:gstin] }
    tax_type { TaxRate.tax_types[:exclusive] }
    business_category { TaxRate.business_categories[:b2b] }
    rate { 12.0 }
    valid_from { Date.current }
    valid_to { Date.current + 1.month }
  end

  trait :inclusive do
    tax_type { TaxRate.tax_types[:inclusive] }
  end

  trait :b2c do
    business_category { TaxRate.business_categories[:b2c] }
  end
end
