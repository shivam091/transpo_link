# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::DeliveryDecisionService < ApplicationService
  def initialize(purchase_order_item, received_quantity)
    @purchase_order_item = purchase_order_item
    @received_quantity = received_quantity
  end

  def call
    decide_delivery_status
  end

  private

  attr_reader :purchase_order_item, :received_quantity

  def decide_delivery_status
    total_received_quantity = purchase_order_item.received_quantity + received_quantity
    ordered_quantity = purchase_order_item.quantity

    if total_received_quantity == ordered_quantity
      PurchaseOrderItems::DeliverService.(purchase_order_item, ordered_quantity)
    else
      PurchaseOrderItems::PartiallyDeliverService.(purchase_order_item, received_quantity)
    end
  end
end
