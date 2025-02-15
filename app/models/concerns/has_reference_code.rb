# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to generate a unique reference code for models that include it.
# The reference code follows a specific format: `[PREFIX]-[NUMBER]`, where:
#   - `PREFIX` is defined in `REFERENCE_CODE_MAPPINGS`
#   - `NUMBER` is an incrementing value, padded to match the required length.
module HasReferenceCode
  extend ActiveSupport::Concern

  included do
    before_create :set_reference_code
  end

  private

  REFERENCE_CODE_LENGTH = 8.freeze
  REFERENCE_CODE_MAPPINGS = {
    "Warehouse" => "WH"
  }.with_indifferent_access.freeze

  def set_reference_code
    return unless has_reference_code_column?

    prefix = REFERENCE_CODE_MAPPINGS[self.class.name] || "XX"

    last_reference_code = self.class.unscope(where: :is_active).maximum(:reference_code)
    new_number = last_reference_code&.scan(/\d+/)&.first.to_i + 1

    number_length = REFERENCE_CODE_LENGTH - (prefix.length + 1)
    self.reference_code = "#{prefix}-#{new_number.to_s.rjust(number_length, '0')}"
  end

  def has_reference_code_column?
    self.class.column_names.include?("reference_code")
  end
end
