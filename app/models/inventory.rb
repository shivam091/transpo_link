# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory < ApplicationRecord
  include HasReferenceCode, Pageable, Sortable, ActsAsMoney

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

  validates :warehouse_id, presence: true, reduce: true
  validates :product_id,
            presence: true,
            uniqueness: {scope: :warehouse_id, message: :uniqueness},
            reduce: true
  validates :inventory_unit,
            presence: true,
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

  validate :inventory_unit_is_in_valid_category

  has_one :stock, inverse_of: :inventory, dependent: :destroy
  has_one :replenishment, inverse_of: :inventory, dependent: :destroy

  has_many :inventory_movements, inverse_of: :inventory, dependent: :destroy
  has_many :inventory_audit_logs, inverse_of: :inventory, dependent: :destroy
  has_many :inventory_batches, inverse_of: :inventory, dependent: :destroy

  belongs_to :warehouse, inverse_of: :inventories
  belongs_to :product, inverse_of: :inventories, touch: true

  default_scope -> { order_created_desc }

  delegate :quantity_in_hand, :quantity_pending_to_buyer, to: :stock
  delegate :quantity_pending_from_supplier, to: :replenishment

  private

  def inventory_unit_is_in_valid_category
    return unless product.present? && inventory_unit.present?

    category = TranspoLink::MeasurementUnits.category_for_unit(product.capacity_unit)
    allowed_units = TranspoLink::MeasurementUnits.units_for(category).map(&:to_s)

    if allowed_units.blank? || !allowed_units.include?(inventory_unit)
      errors.add(:inventory_unit, :inclusion)
    end
  end
end
