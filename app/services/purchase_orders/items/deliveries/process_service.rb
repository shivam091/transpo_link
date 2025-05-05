# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::Items::Deliveries::ProcessService < ApplicationService
  def initialize(delivery)
    @delivery = delivery
  end

  def call
    process_delivery!
  end

  private

  attr_reader :delivery

  def process_delivery!
    item = delivery.item
    inventory = item.inventory

    # Create inventory movement
    purchase_attributes = {
      quantity: delivery.quantity,
      unit_id: item.unit_id,
      unit_cost: item.unit_cost,
      total_cost: item.total_cost,
      currency: item.currency,
    }
    Inventories::Movements::PurchaseService.(inventory, item, purchase_attributes)

    # Update received quantity
    PurchaseOrders::Items::UpdateReceivedQuantityService.(item, delivery.quantity)

    # Decrement replenishment
    source_unit, target_unit = delivery.unit, inventory.unit
    converted_quantity = UnitConversion.convert(source_unit, target_unit, delivery.quantity)
    Replenishments::UpdateService.(inventory, converted_quantity, :decrement)

    # Evaluate delivery status
    PurchaseOrders::Items::EvaluateDeliveryStatusService.(item)
  end
end
