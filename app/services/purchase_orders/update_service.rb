# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::UpdateService < ApplicationService
  def initialize(purchase_order, purchase_order_attributes)
    @purchase_order, @purchase_order_attributes = purchase_order, purchase_order_attributes
  end

  def call
    update_purchase_order
  end

  private

  attr_reader :purchase_order, :purchase_order_attributes

  def update_purchase_order
    if purchase_order.update(purchase_order_attributes)
      ServiceResponse.success(payload: {purchase_order:})
    else
      ServiceResponse.error(payload: {purchase_order:})
    end
  end
end
