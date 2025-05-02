# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::ProcessDeliveryService < ApplicationService
  def initialize(purchase_order_item, received_quantity)
    @purchase_order_item = purchase_order_item
    @received_quantity = received_quantity
  end

  def call
    PurchaseOrderItem.transaction do
      update_received_quantity!
      decrement_replenishment!
      decide_delivery_status
    end
  end

  private

  attr_reader :purchase_order_item, :received_quantity

  def update_received_quantity!
    result = PurchaseOrderItems::UpdateReceivedQuantityService.(purchase_order_item, received_quantity)

    raise ActiveRecord::Rollback if result.error?
  end

  def decrement_replenishment!
    warehouse, product = purchase_order_item.warehouse, purchase_order_item.product
    inventory = warehouse.inventories.for_product(product)

    source_unit, target_unit = purchase_order_item.unit, inventory.unit
    quantity = UnitConversion.convert(source_unit, target_unit, received_quantity)

    Replenishments::UpdateService.(inventory, quantity, :decrement)
  end

  def decide_delivery_status
    total_received_quantity = purchase_order_item.received_quantity
    ordered_quantity = purchase_order_item.quantity

    if ordered_quantity == total_received_quantity
      deliver_purchase_order_item
    else
      partially_deliver_purchase_order_item
    end
  end

  def deliver_purchase_order_item
    PurchaseOrderItems::DeliverService.(purchase_order_item)
  end

  def partially_deliver_purchase_order_item
    PurchaseOrderItems::PartiallyDeliverService.(purchase_order_item)
  end
end
