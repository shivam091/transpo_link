# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductPrice < ApplicationRecord
  include Sortable, ActsAsMoney, ScaleEnforcer

  LISTING_ATTRIBUTES = %i[warehouse_id min_quantity unit_price].freeze
  GLOBAL_WAREHOUSE_ID = "00000000-0000-0000-0000-000000000000".freeze

  attribute :effective_from, :date
  attribute :effective_until, :date

  scale_attributes :min_quantity, :unit_price

  validates :min_quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_id, presence: true, reduce: true
  validates :unit_price,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :effective_from,
            presence: true,
            comparison: {greater_than_or_equal_to: Date.current},
            reduce: true
  validates :effective_until,
            presence: true,
            comparison: {greater_than_or_equal_to: :effective_from},
            reduce: true

  validate :warehouse_unit_is_in_product_unit_category

  with_options inverse_of: :product_prices do |a|
    a.belongs_to :product, touch: true
    a.belongs_to :warehouse, optional: true
    a.belongs_to :unit
  end

  before_validation :set_effective_period_from_virtual_attributes

  delegate :name, to: :warehouse, prefix: true, allow_nil: true

  default_scope { order_created_desc }

  def effective_from
    super || effective_period&.begin
  end

  def effective_until
    ep = effective_period
    return super if super.present?
    return nil if ep.nil?

    ep.exclude_end? ? ep.end.prev_day : ep.end
  end

  private

  def set_effective_period_from_virtual_attributes
    return unless effective_from && effective_until

    self.effective_period = effective_from..effective_until
  end

  def warehouse_unit_is_in_product_unit_category
    return unless warehouse && product

    allowed_units ||= Unit.for_category(product.unit_category).symbols

    if allowed_units.blank? || allowed_units.exclude?(warehouse.unit_symbol)
      errors.add(:warehouse_id, :unit_category_mismatch)
    end
  end
end
