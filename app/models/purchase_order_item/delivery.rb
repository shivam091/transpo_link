# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItem::Delivery < ApplicationRecord
  include ScaleEnforcer, NullifyIfBlank, Sanitizable

  scale_attributes :quantity

  nullify_if_blank :note

  sanitize_attributes :comment, :note

  # Virtual attributes to preserve user input
  attr_accessor :original_quantity, :original_unit_id

  validates :quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_id,
            presence: true,
            reduce: true
  validates :comment,
            presence: true,
            length: {maximum: 1000},
            reduce: true
  validates :note,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true

  validate :converted_quantity_must_not_exceed_remaining_quantity

  belongs_to :purchase_order_item, inverse_of: :deliveries
  belongs_to :unit, inverse_of: :delivered_po_items

  before_validation :store_original_attributes, :convert_to_item_unit
  after_create :process_delivery

  private

  def store_original_attributes
    self.original_quantity ||= quantity
    self.original_unit_id ||= unit_id
  end

  def convert_to_item_unit
    return unless unit && quantity
    return if (source_unit = unit) == (target_unit = purchase_order_item.unit)

    self.quantity = UnitConversion.convert!(source_unit, target_unit, quantity)
    self.unit = target_unit # Store in item unit
  end

  def converted_quantity_must_not_exceed_remaining_quantity
    return unless quantity && unit

    if quantity > purchase_order_item.remaining_quantity
      errors.add(:quantity, :exceeds_remaining_quantity, message: "exceeds remaining quantity for the item")
    end
  end

  def process_delivery
    PurchaseOrderItems::Deliveries::ProcessService.(self)
  end
end
