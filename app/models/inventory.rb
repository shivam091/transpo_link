# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory < ApplicationRecord
  include HasReferenceCode, Pageable, Sortable, ActsAsMoney, Navigable

  LISTING_ATTRIBUTES = %i[
    reference_code product_id warehouse_id tracking_method low_stock_threshold
    average_cost_price
  ].freeze

  enum :tracking_method, {
    fifo: "fifo",
    lifo: "lifo",
    average_cost: "average_cost",
  }

  attribute :average_cost_price, default: 0.0
  attribute :tracking_method, :enum, default: tracking_methods[:average_cost]

  validates :warehouse_id, :unit_id, presence: true, reduce: true
  validates :product_id,
            presence: true,
            uniqueness: {scope: :warehouse_id, message: :uniqueness},
            reduce: true
  validates :tracking_method,
            presence: true,
            inclusion: {in: tracking_methods.values},
            reduce: true
  validates :low_stock_threshold,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :average_cost_price,
            presence: true,
            numericality: {greater_than_or_equal_to: 0.0},
            reduce: true

  validate :inventory_unit_matches_product_unit_category
  validate :product_unit_category_matches_warehouse_capacity

  with_options inverse_of: :inventory, dependent: :destroy do |a|
    a.has_one :stock
    a.has_one :replenishment

    a.has_many :inventory_movements
    a.has_many :inventory_audit_logs
    a.has_many :inventory_batches
  end

  with_options inverse_of: :inventories do |a|
    a.belongs_to :warehouse
    a.belongs_to :product, touch: true
    a.belongs_to :unit
  end

  delegate :quantity_in_hand, :quantity_pending_to_buyer, to: :stock
  delegate :quantity_pending_from_supplier, to: :replenishment
  delegate :symbol, to: :unit, prefix: true

  def key_associations
    [product, warehouse]
  end

  private

  def inventory_unit_matches_product_unit_category
    return unless product.present? && unit.present?

    allowed_units = Unit.for_category(product.unit_category).map(&:symbol)

    if allowed_units.blank? || !allowed_units.include?(unit_symbol)
      errors.add(:unit_id, :incompatible_unit_category)
    end
  end

  def product_unit_category_matches_warehouse_capacity
    return unless warehouse.present? && product.present?

    allowed_units = Unit.for_category(warehouse.unit_category).map(&:symbol)

    if allowed_units.blank? || !allowed_units.include?(product.unit_symbol)
      errors.add(:product_id, :incompatible_unit_category)
    end
  end
end
