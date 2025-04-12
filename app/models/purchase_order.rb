# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrder < ApplicationRecord
  include AASM, HasReferenceCode, Sanitizable, NullifyIfBlank, Pageable, Navigable

  LISTING_ATTRIBUTES = %i[
    reference_code warehouse_id manager_id supplier_id order_date expected_delivery_date
    status
  ].freeze

  enum :status, {
    draft: "draft",
    pending: "pending",
    approved: "approved",
    cancelled: "cancelled",
    rejected: "rejected",
    partially_delivered: "partially_delivered",
    fully_delivered: "fully_delivered"
  }

  attribute :status, :enum, default: statuses[:draft]

  sanitize_attributes :reference_document, :notes

  nullify_if_blank :reference_document, :notes, :expected_delivery_date

  aasm column: :status, enum: true, requires_lock: true do
    state :draft, initial: true
    state :pending, :approved, :cancelled, :rejected, :partially_delivered, :fully_delivered

    event :cancel do
      transitions from: [:draft, :pending], to: :cancelled
    end

    event :submit do
      transitions from: :draft, to: :pending
    end

    event :approve do
      transitions from: :pending, to: :approved
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end

    event :partially_deliver do
      transitions from: :approved, to: :partially_delivered
    end

    event :fully_deliver do
      transitions from: [:approved, :partially_delivered], to: :fully_delivered
    end
  end

  validates :warehouse_id, :manager_id, :supplier_id, presence: true, reduce: true
  validates :reference_document,
            length: {maximum: 55},
            allow_blank: true,
            reduce: true
  validates :expected_delivery_date,
            comparison: {greater_than_or_equal_to: :order_date},
            allow_nil: true,
            reduce: true
  validates :status,
            presence: true,
            inclusion: {in: statuses.values, message: :inclusion},
            reduce: true
  validates :notes,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true

  has_many :purchase_order_items, inverse_of: :purchase_order, dependent: :destroy

  belongs_to :warehouse, inverse_of: :purchase_orders
  belongs_to :manager, inverse_of: :purchase_orders, class_name: "User"
  belongs_to :supplier, inverse_of: :supplied_purchase_orders, class_name: "User"

  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true, reject_if: :reject_purchase_order_item?

  class << self
    def accessible(user)
      user.purchase_orders
    end
  end

  def key_associations
    [warehouse, manager, supplier]
  end

  private

  def reject_purchase_order_item?(attributes)
    [
      attributes[:purchase_order_id],
      attributes[:product_id],
      attributes[:unit_id],
      attributes[:currency]
    ].all?(&:blank?) && attributes[:quantity].to_d.zero?
  end
end
