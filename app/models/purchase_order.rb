# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# == Status Definitions
#
# draft: PO is being created but not yet submitted. Editable.
# submitted: PO has been submitted for approval or processing.
# approved: PO has been reviewed and approved. Can now be acted on.
# shipped: PO has been shipped by the supplier.
# partially_delivered: Some items in the PO have been received.
# fully_delivered: All items in the PO have been fully received.
# cancelled: PO was cancelled before completion. No further processing.
# rejected: PO was denied during approval
# closed: PO is manually or automatically marked complete. No further actions.
# on_hold: PO is temporarily paused (e.g., awaiting funding or clarification).

class PurchaseOrder < ApplicationRecord
  include AASM, HasReferenceCode, Sanitizable, NullifyIfBlank, Pageable, Navigable

  LISTING_ATTRIBUTES = %i[
    reference_code warehouse_id manager_id supplier_id order_date expected_delivery_date
    status
  ].freeze

  enum :status, {
    draft: "draft",
    submitted: "submitted",
    approved: "approved",
    shipped: "shipped",
    partially_delivered: "partially_delivered",
    fully_delivered: "fully_delivered",
    cancelled: "cancelled",
    rejected: "rejected",
    closed: "closed",
    on_hold: "on_hold"
  }

  attribute :status, default: statuses[:draft]

  sanitize_attributes :reference_document, :notes

  nullify_if_blank :reference_document, :notes, :expected_delivery_date

  aasm column: :status, enum: true, requires_lock: true do
    state :draft, initial: true
    state :submitted, :approved, :shipped, :cancelled, :rejected, :partially_delivered,
          :fully_delivered, :closed, :on_hold

    event :submit do
      transitions from: :draft, to: :submitted
    end

    event :approve do
      transitions from: :submitted, to: :approved

      after :replenish_inventory!
    end

    event :ship do
      transitions from: :approved, to: :shipped
    end

    event :reject do
      transitions from: :submitted, to: :rejected
    end

    event :cancel do
      transitions from: [:draft, :submitted, :on_hold], to: :cancelled

      after :cancel_purchase_order_items!
    end

    event :hold do
      transitions from: [:submitted, :approved], to: :on_hold
    end

    event :resume do
      transitions from: :on_hold, to: :approved
    end

    event :partially_deliver do
      transitions from: :approved, to: :partially_delivered
    end

    event :fully_deliver do
      transitions from: [:approved, :partially_delivered], to: :fully_delivered

      before :update_actual_delivery_date
      after :deliver_purchase_order_items!
    end

    event :close do
      transitions from: :fully_delivered, to: :closed
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

  validates_associated :purchase_order_items

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

  # Method to synchronize PO status based on PO Items' status
  def synchronize_delivery_status!
    if all_items_delivered?
      fully_deliver! if may_fully_deliver?
    elsif some_items_delivered_or_partially_delivered?
      partially_deliver! if may_partially_deliver?
    else
      # No automatic fallback. Just stay in current status.
    end
  rescue AASM::InvalidTransition => e
    Rails.logger.error("Failed to synchronize PO delivery status: #{e.message}")
  end

  private

  def all_items_delivered?
    purchase_order_items.all?(&:delivered?)
  end

  def some_items_delivered_or_partially_delivered?
    purchase_order_items.any? { |item| item.status.in?(["delivered", "partially_delivered"]) }
  end

  def reject_purchase_order_item?(attributes)
    [
      attributes[:purchase_order_id],
      attributes[:product_id],
      attributes[:unit_id],
      attributes[:currency],
      attributes[:quantity]
    ].all?(&:blank?)
  end

  def replenish_inventory!
    Inventories::ReplenishService.(self)
  end

  def cancel_purchase_order_items!
    purchase_order_items.each do |purchase_order_item|
      PurchaseOrderItems::CancelService.(purchase_order_item)
    end
  end

  def deliver_purchase_order_items!
    purchase_order_items.each do |purchase_order_item|
      PurchaseOrderItems::DeliverService.(purchase_order_item)
    end
  end

  def update_actual_delivery_date
    update_column(:actual_delivery_date, Date.current)
  end
end
