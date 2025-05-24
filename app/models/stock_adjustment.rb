# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class StockAdjustment < ApplicationRecord
  include ScaleEnforcer, NullifyIfBlank, Sanitizable

  # 'automatic' adjustment type is not listed here as it's system assigned.
  enum :adjustment_type, {
    increase: "increase",
    decrease: "decrease"
  }

  enum :adjustment_reason, {
    stock_count_discrepancy: "stock_count_discrepancy",
    damaged_goods: "damaged_goods",
    expired_stock: "expired_stock",
    theft_or_loss: "theft_or_loss",
    sample_issued: "sample_issued",
    administrative_correction: "administrative_correction",
    misplaced_then_found: "misplaced_then_found",
    overstock_correction: "overstock_correction",
    shrinkage: "shrinkage",
    pallet_breakage: "pallet_breakage",
    found_during_audit: "found_during_audit",
    cycle_count_adjustment: "cycle_count_adjustment",
    donated: "donated",
    disposal: "disposal",
    used_internally: "used_internally",
  }

  scale_attributes :adjusted_quantity

  nullify_if_blank :note

  sanitize_attributes :note

  validates :adjusted_quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :adjustment_type,
            presence: true,
            inclusion: {in: adjustment_types.values, message: :inclusion},
            reduce: true
  validates :adjustment_reason,
            presence: true,
            inclusion: {in: adjustment_reasons.values, message: :inclusion},
            reduce: true
  validates :unit_id,
            presence: true,
            reduce: true
  validates :note,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true

  belongs_to :adjustable, inverse_of: :stock_adjustments, polymorphic: true
  belongs_to :source, inverse_of: :stock_adjustments, polymorphic: true, optional: true
  belongs_to :inventory, inverse_of: :stock_adjustments, optional: true
  belongs_to :user, inverse_of: :stock_adjustments
  belongs_to :unit, inverse_of: :stock_adjustments

  before_create :set_inventory_id

  private

  def set_inventory_id
    return if inventory_id.present?

    if adjustable.respond_to?(:inventory_id)
      self.inventory_id = adjustable.inventory_id
    else
      raise ArgumentError, "Missing inventory on adjustable"
    end
  end
end
