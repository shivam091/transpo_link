# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::Delivery
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :purchase_order_item, :quantity, :unit

  validates :quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit,
            presence: true,
            reduce: true

  before_validation :normalize_attributes

  def process!
    return false unless valid?

    received_quantity = self.quantity

    unless (source_unit = self.unit) == (target_unit = purchase_order_item.unit)
      received_quantity = UnitConversion.convert(source_unit, target_unit, received_quantity)
    end

    PurchaseOrderItems::ProcessDeliveryService.(purchase_order_item, received_quantity)
  end

  private

  def normalize_attributes
    self.quantity = (BigDecimal(quantity.to_s) rescue 0.0) if quantity.present?
    self.unit = Unit.find_by(id: unit) if unit.is_a?(String)
  end
end
