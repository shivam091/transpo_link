# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::Items::UpdateReceivedQuantityService < ApplicationService
  def initialize(purchase_order_item, quantity)
    @purchase_order_item = purchase_order_item
    @quantity = quantity
  end

  def call
    update_received_quantity!
  end

  private

  attr_reader :purchase_order_item, :quantity

  def update_received_quantity!
    purchase_order_item.lock!

    new_received_quantity = purchase_order_item.received_quantity + quantity
    max_allowed = purchase_order_item.quantity

    final_quantity = [new_received_quantity, max_allowed].min

    if purchase_order_item.update(received_quantity: final_quantity)
      ServiceResponse.success(payload: {purchase_order_item:})
    else
      ServiceResponse.error(payload: {purchase_order_item:})
    end
  end
end
