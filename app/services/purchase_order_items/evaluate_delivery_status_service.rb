# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::EvaluateDeliveryStatusService < ApplicationService
  def initialize(purchase_order_item)
    @purchase_order_item = purchase_order_item
  end

  def call
    evaluate_delivery_status
  end

  private

  attr_reader :purchase_order_item

  def evaluate_delivery_status
    total_received_quantity = purchase_order_item.received_quantity
    ordered_quantity = purchase_order_item.quantity

    if total_received_quantity >= ordered_quantity
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
