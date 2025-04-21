# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItem < ApplicationRecord
  include AASM, ActsAsMoney, Sortable

  LISTING_ATTRIBUTES = %i[product_id quantity unit_cost total_cost status].freeze

  enum :status, {
    pending: "pending",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  attribute :received_quantity, default: 0.0
  attribute :status, :enum, default: statuses[:pending]

  aasm column: :status, enum: true, requires_lock: true do
    state :pending, initial: true
    state :delivered, :cancelled

    event :cancel do
      transitions from: :pending, to: :cancelled
    end

    event :deliver do
      transitions from: :pending, to: :delivered
    end
  end

  validates :product_id,
            presence: true,
            reduce: true
  validates :quantity, :unit_cost,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :received_quantity,
            presence: true,
            numericality: {greater_than_or_equal_to: 0.0},
            reduce: true
  validates :unit_id, presence: true, reduce: true
  validates :status,
            presence: true,
            inclusion: {in: statuses.values, message: :inclusion},
            reduce: true

  validate :product_unit_is_in_warehouse_unit_category

  validates_with UnitIsInProductUnitCategoryValidator
  validates_with UniqueProductInCollectionValidator, parent: :purchase_order, collection: :purchase_order_items

  with_options inverse_of: :purchase_order_items do |a|
    a.belongs_to :purchase_order, touch: true
    a.belongs_to :product
    a.belongs_to :unit
  end

  before_validation :set_unit_cost_and_currency

  delegate :symbol, to: :unit, prefix: true

  default_scope -> { order_created_desc }

  private

  def product_unit_is_in_warehouse_unit_category
    return unless (warehouse = purchase_order&.warehouse) && product

    allowed_units = Unit.for_category(warehouse.unit_category).symbols

    if allowed_units.blank? || allowed_units.exclude?(product.unit_symbol)
      errors.add(:product_id, :unit_category_mismatch)
    end
  end

  def set_unit_cost_and_currency
    return unless will_save_change_to_product_id?

    if product
      assign_attributes(unit_cost: product.cost_price, currency: product.currency)
    end
  end
end
