# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::IncrementReceivedQuantityService < ApplicationService
  def initialize(purchase_order_item, quantity)
    @purchase_order_item = purchase_order_item
    @quantity = quantity
  end

  def call
    increment_received_quantity!
  end

  private

  attr_reader :purchase_order_item, :quantity

  def increment_received_quantity!
    if purchase_order_item.increment!(:received_quantity, quantity)
      ServiceResponse.success(payload: {purchase_order_item:})
    else
      ServiceResponse.error(payload: {purchase_order_item:})
    end
  end
end
