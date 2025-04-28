# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# == Status Definitions
#
# pending: Default state when item is added to PO. Not yet processed.
# ordered: Item has been included in an approved order.
# partially_delivered: Some quantity of the item has been received.
# delivered: Entire quantity of the item has been received.
# backordered: Item is on backorder, waiting for vendor stock.
# cancelled: Item was removed from the order or no longer needed.
# returned: Item was received and later returned.
# damaged: Item was received in poor condition and flagged.

class PurchaseOrderItem < ApplicationRecord
  include AASM, ActsAsMoney, Sortable

  LISTING_ATTRIBUTES = %i[product_id quantity unit_cost total_cost status].freeze

  enum :status, {
    pending: "pending",
    ordered: "ordered",
    partially_delivered: "partially_delivered",
    delivered: "delivered",
    backordered: "backordered",
    cancelled: "cancelled",
    returned: "returned",
    damaged: "damaged",
  }

  attribute :received_quantity, default: 0.0
  attribute :status, :enum, default: statuses[:pending]

  aasm column: :status, enum: true, requires_lock: true do
    state :pending, initial: true
    state :ordered, :partially_delivered, :delivered, :cancelled, :returned,
          :damaged, :backordered

    event :place_order do
      transitions from: :pending, to: :ordered
    end

    event :cancel do
      transitions from: [:pending, :ordered], to: :cancelled
    end

    event :partially_deliver do
      transitions from: :pending, to: :partially_delivered

      after :synchronize_po_delivery_status!
    end

    event :deliver do
      transitions from: [:pending, :partially_delivered], to: :delivered

      after :synchronize_po_delivery_status!
    end

    event :return_item do
      transitions from: :delivered, to: :returned
    end

    event :mark_damaged do
      transitions from: :delivered, to: :damaged
    end

    event :backorder do
      transitions from: [:pending, :partially_delivered], to: :backordered
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

  has_many :restocks,
           -> {
             where(InventoryMovement.arel_table[:movement_type].eq(InventoryMovement.movement_types[:restock]))
           },
           class_name: "InventoryMovement",
           as: :source,
           dependent: :restrict_with_exception

  before_validation :set_unit_cost_and_currency

  with_options prefix: true do |d|
    d.delegate :symbol, to: :unit
    d.delegate :name, to: :product
  end

  default_scope -> { order_created_desc }

  def remaining_quantity
    quantity - received_quantity
  end

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

  def synchronize_po_delivery_status!
    purchase_order.synchronize_delivery_status!
  end
end
