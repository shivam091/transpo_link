# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Custom validator for checking whether attribute's value is valid tax identifier.
#
# Example:
#
#   class Model < ActiveRecord::Base
#     validates :attribute, tax_identifier: true
#   end
#
class TaxIdentifierValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    error_message = options[:message] || :invalid
    tax_identifier_type = record.tax_identifier_type&.to_sym
    country = record.country&.to_sym

    return if tax_identifier_type.blank? || value.blank?

    pattern = fetch_pattern(tax_identifier_type, country)

    unless pattern.nil? || value =~ pattern
      record.errors.add(attribute, error_message)
    end
  end

  private

  def fetch_pattern(tax_identifier_type, country)
    tax_identifier_patterns = TranspoLink::Regex::TAX_IDENTIFIER_PATTERNS

    tax_identifier_patterns.dig(tax_identifier_type, country)
  end
end
