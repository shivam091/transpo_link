# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::PartialDeliveryService < ApplicationService
  def initialize(purchase_order)
    @purchase_order = purchase_order
  end

  def call
    partially_deliver_purchase_order
  end

  private

  attr_reader :purchase_order

  def partially_deliver_purchase_order
    if purchase_order.may_partially_deliver? && purchase_order.partially_deliver!
      ServiceResponse.success(payload: {purchase_order:})
    else
      ServiceResponse.error(payload: {purchase_order:})
    end
  end
end
