# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to generate a unique reference code for models that include it.
module HasReferenceCode
  extend ActiveSupport::Concern

  included do
    after_initialize :set_reference_code, if: :code_required?
  end

  private

  REFERENCE_CODE_LENGTH = 10.freeze

  def set_reference_code
    self.reference_code = SecureRandom.alphanumeric(REFERENCE_CODE_LENGTH).upcase
  end

  def has_reference_code_column?
    self.class.column_names.include?("reference_code")
  end

  def code_required?
    return unless has_reference_code_column?

    reference_code.blank?
  end
end
