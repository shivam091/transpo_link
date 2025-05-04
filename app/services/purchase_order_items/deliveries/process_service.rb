# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::Deliveries::ProcessService < ApplicationService
  def initialize(delivery)
    @delivery = delivery
  end

  def call
    process_delivery!
  end

  private

  attr_reader :delivery

  def process_delivery!
    purchase_order_item = delivery.purchase_order_item
    inventory = purchase_order_item.inventory

    # Create inventory movement
    purchase_attributes = {
      quantity: delivery.quantity,
      unit_id: purchase_order_item.unit_id,
      unit_cost: purchase_order_item.unit_cost,
      total_cost: purchase_order_item.total_cost,
      currency: purchase_order_item.currency,
    }
    InventoryMovements::PurchaseService.(inventory, purchase_order_item, purchase_attributes)

    # Update received quantity
    PurchaseOrderItems::UpdateReceivedQuantityService.(purchase_order_item, delivery.quantity)

    # Decrement replenishment
    source_unit, target_unit = delivery.unit, inventory.unit
    converted_quantity = UnitConversion.convert(source_unit, target_unit, delivery.quantity)
    Replenishments::UpdateService.(inventory, converted_quantity, :decrement)

    # Evaluate delivery status
    PurchaseOrderItems::EvaluateDeliveryStatusService.(purchase_order_item)
  end
end
