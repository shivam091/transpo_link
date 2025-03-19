# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Custom validator for checking whether attribute's value is valid business
# identifier.
#
# Example:
#
#   class Model < ActiveRecord::Base
#     validates :attribute, business_identifier: true
#   end
#
class BusinessIdentifierValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    error_message = options[:message] || :invalid
    business_identifier_type = record.business_identifier_type&.to_sym
    country = record.country&.to_sym

    return if business_identifier_type.blank? || value.blank?

    pattern = fetch_pattern(business_identifier_type, country)

    unless pattern.nil? || value =~ pattern
      record.errors.add(attribute, error_message)
    end
  end

  private

  def fetch_pattern(business_identifier_type, country)
    business_identifier_patterns = TranspoLink::Regex::BUSINESS_IDENTIFIER_PATTERNS

    business_identifier_patterns.dig(business_identifier_type, country)
  end
end
