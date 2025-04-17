# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::CancelService < ApplicationService
  def initialize(purchase_order_item)
    @purchase_order_item = purchase_order_item
  end

  def call
    cancel_purchase_order_item
  end

  private

  attr_reader :purchase_order_item

  def cancel_purchase_order_item
    if purchase_order_item.may_cancel? && purchase_order_item.cancel!
      ServiceResponse.success(payload: {purchase_order_item:})
    else
      ServiceResponse.error(payload: {purchase_order_item:})
    end
  end
end
