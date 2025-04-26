# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::PartiallyDeliverService < ApplicationService
  def initialize(purchase_order_item, quantity)
    @purchase_order_item = purchase_order_item
    @quantity = quantity
  end

  def call
    partially_deliver_purchase_order_item
  end

  private

  attr_reader :purchase_order_item, :quantity

  def partially_deliver_purchase_order_item
    if purchase_order_item.may_partially_deliver? && purchase_order_item.partially_deliver!(quantity)
      ServiceResponse.success(payload: {purchase_order_item:})
    else
      ServiceResponse.error(payload: {purchase_order_item:})
    end
  end
end
