# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItem < ApplicationRecord
  include AASM, ActsAsMoney

  LISTING_ATTRIBUTES = %i[product_id quantity unit_cost total_cost status].freeze

  enum :status, {
    pending: "pending",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  attribute :quantity, default: 0.0
  attribute :received_quantity, default: 0.0
  attribute :unit_cost, default: 0.0
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
            uniqueness: {scope: :purchase_order_id, message: :uniqueness},
            reduce: true
  validates :quantity, :unit_cost,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :received_quantity,
            presence: true,
            numericality: {greater_than_or_equal_to: 0.0},
            reduce: true
  validates :uom,
            presence: true,
            reduce: true
  validates :status,
            presence: true,
            inclusion: {in: statuses.values, message: :inclusion},
            reduce: true

  belongs_to :purchase_order, inverse_of: :purchase_order_items
  belongs_to :product, inverse_of: :purchase_order_items

  before_validation :set_unit_cost_and_currency

  private

  def set_unit_cost_and_currency
    return unless will_save_change_to_product_id?

    if product.present?
      assign_attributes(unit_cost: product.cost_price, currency: product.currency)
    end
  end
end
