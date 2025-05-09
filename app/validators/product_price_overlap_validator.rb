# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductPriceOverlapValidator < ActiveModel::Validator
  def validate(record)
    return unless (product_id = record.product_id) && (effective_period = record.effective_period)

    # We are checking for overlapping periods with existing prices in the same product
    overlapping = ProductPrice
      .where(product_id: record.product_id, unit_id: record.unit_id, currency: record.currency&.iso_code)
      .with_normalized_warehouse(record.warehouse_id)
      .where.not(id: record.id)
      .where("effective_period && daterange(?, ?, '[]')", effective_period.begin, effective_period.end) # '&&' checks for overlap

    if overlapping.exists?
      record.errors.add(:effective_from, :overlaps_with_existing_price_tier)
      record.errors.add(:effective_until, :overlaps_with_existing_price_tier)
    end

    if record.product&.product_prices&.loaded?
      # Select unsaved, in-memory sibling records only
      sibling_ranges = record.product.product_prices.select do |pp|
        pp != record &&
          pp.new_record? &&
          !pp.marked_for_destruction? &&
          pp.unit_id == record.unit_id &&
          pp.currency == record.currency&.iso_code &&
          (pp.warehouse_id.presence || ProductPrice::GLOBAL_WAREHOUSE_ID) == record.warehouse_id &&
          pp.effective_period.present?
      end.map(&:effective_period)

      if overlaps_any?(record.effective_period, sibling_ranges)
        record.errors.add(:effective_from, :overlaps_with_new_price_tier)
        record.errors.add(:effective_until, :overlaps_with_new_price_tier)
      end
    end
  end

  private

  # Only checks overlap if needed, not eager on all records
  def overlaps_any?(range, others)
    others.any? { |other| range.overlaps?(other) }
  end
end
