# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to generate a unique reference code for models that include it.
# The reference code follows a specific format: `[PREFIX]-[NUMBER]`, where:
#   - `PREFIX` is defined in `REFERENCE_CODE_CONFIG` based on the model's name.
#   - `NUMBER` is an incrementing value, padded to match the required length.
#
# Models that include this module will have a `before_create` callback
# that automatically generates a unique reference code for each record before saving it.
#
# The reference code format is determined by:
#   - The `prefix` specified for the model (e.g., `WH` for Warehouse, `PRD` for Product, etc.)
#   - The incrementing `number` pulled from the model-specific sequence.
#
# The sequence for each model is configured in the `REFERENCE_CODE_CONFIG` constant.
module HasReferenceCode
  extend ActiveSupport::Concern

  included do
    before_create :set_reference_code, if: :has_reference_code_column?
  end

  private

  REFERENCE_CODE_LENGTH = 4.freeze
  REFERENCE_CODE_CONFIG = {
    "Warehouse" => {prefix: "WH", seq_name: "warehouse_reference_code_seq"},
    "Product" => {prefix: "PRD", seq_name: "product_reference_code_seq"},
    "Inventory" => {prefix: "INV", seq_name: "inventory_reference_code_seq"},
    "Feedback" => {prefix: "FBK", seq_name: "feedback_reference_code_seq"},
    "PurchaseOrder" => {prefix: "PO", seq_name: "po_reference_code_seq"}
  }

  def set_reference_code
    mapping = REFERENCE_CODE_CONFIG.fetch(self.class.name)
    prefix = mapping.fetch(:prefix)
    seq_name = mapping.fetch(:seq_name)

    self.reference_code = format("%s-%0*d", prefix, REFERENCE_CODE_LENGTH, next_reference_code(seq_name))
  end

  def has_reference_code_column?
    self.class.column_names.include?("reference_code")
  end

  def next_reference_code(seq_name)
    self.class.connection.select_value("SELECT nextval('#{seq_name}')")
  end
end
