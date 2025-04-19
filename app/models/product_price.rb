# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductPrice < ApplicationRecord
  include Sortable, ActsAsMoney

  LISTING_ATTRIBUTES = %i[warehouse_id min_quantity unit_price].freeze

  validates :min_quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_price,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true

  validate :warehouse_unit_is_in_product_unit_category

  with_options inverse_of: :product_prices do |a|
    a.belongs_to :product, touch: true
    a.belongs_to :warehouse, optional: true
  end

  delegate :name, to: :warehouse, prefix: true, allow_nil: true

  default_scope { order_created_desc }

  private

  def warehouse_unit_is_in_product_unit_category
    return unless warehouse.present? && product.present?

    allowed_units = Unit.for_category(product.unit_category).symbols

    if allowed_units.blank? || !allowed_units.include?(warehouse.unit_symbol)
      errors.add(:warehouse_id, :unit_category_mismatch)
    end
  end
end
