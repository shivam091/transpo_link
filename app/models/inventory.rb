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

  has_one :stock, inverse_of: :inventory, dependent: :destroy
  has_one :replenishment, inverse_of: :inventory, dependent: :destroy

  has_many :inventory_movements, inverse_of: :inventory, dependent: :destroy
  has_many :inventory_audit_logs, inverse_of: :inventory, dependent: :destroy
  has_many :inventory_batches, inverse_of: :inventory, dependent: :destroy

  belongs_to :warehouse, inverse_of: :inventories
  belongs_to :product, inverse_of: :inventories, touch: true
  belongs_to :unit, inverse_of: :inventories

  after_create :create_stock, :create_replenishment

  delegate :quantity_in_hand, :quantity_pending_to_buyer, to: :stock
  delegate :quantity_pending_from_supplier, to: :replenishment
  delegate :symbol, to: :unit, prefix: true

  class << self
    def for_product(product)
      find_by(arel_table[:product_id].eq(product.id))
    end
  end

  def key_associations
    [product, warehouse]
  end

  private

  def create_stock
    Stock.create!(inventory: self)
  end

  def create_replenishment
    Replenishment.create!(inventory: self)
  end

  def inventory_unit_matches_product_unit_category
    return unless product.present? && unit.present?

    allowed_units = Unit.for_category(product.unit_category).symbols

    if allowed_units.blank? || !allowed_units.include?(unit_symbol)
      errors.add(:unit_id, :incompatible_unit_category)
    end
  end

  def product_unit_category_matches_warehouse_capacity
    return unless warehouse.present? && product.present?

    allowed_units = Unit.for_category(warehouse.unit_category).symbols

    if allowed_units.blank? || !allowed_units.include?(product.unit_symbol)
      errors.add(:product_id, :incompatible_unit_category)
    end
  end
end
