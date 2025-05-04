# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::Delivery < ApplicationRecord
  self.table_name = :purchase_order_item_deliveries

  include ScaleEnforcer

  scale_attributes :quantity

  validates :quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_id,
            presence: true,
            reduce: true

  belongs_to :purchase_order_item, inverse_of: :deliveries
  belongs_to :unit, inverse_of: :delivered_po_items

  before_create :convert_to_item_unit

  private

  def convert_to_item_unit
    return if (source_unit = unit) == (target_unit = purchase_order_item.unit)

    self.quantity = UnitConversion.convert(source_unit, target_unit, quantity)
    self.unit = target_unit # Store in item unit
  end
end
