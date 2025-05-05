# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::Items::ProcessDeliveryService < ApplicationService
  def initialize(purchase_order_item, received_quantity)
    @purchase_order_item = purchase_order_item
    @received_quantity = received_quantity
  end

  def call
    PurchaseOrder::Item.transaction do
      update_received_quantity!
      decide_delivery_status
    end
  end

  private

  attr_reader :purchase_order_item, :received_quantity

  def update_received_quantity!
    result = PurchaseOrders::Items::UpdateReceivedQuantityService.(purchase_order_item, received_quantity)

    raise ActiveRecord::Rollback if result.error?
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
    PurchaseOrders::Items::DeliverService.(purchase_order_item)
  end

  def partially_deliver_purchase_order_item
    PurchaseOrders::Items::PartiallyDeliverService.(purchase_order_item)
  end
end
