# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::CreateService < ApplicationService
  def initialize(manager, purchase_order_attributes)
    @manager, @purchase_order_attributes = manager, purchase_order_attributes
  end

  def call
    create_purchase_order
  end

  private

  attr_reader :manager, :purchase_order_attributes

  def create_purchase_order
    purchase_order = manager.purchase_orders.build(purchase_order_attributes)

    if purchase_order.save
      ServiceResponse.success(payload: {purchase_order:})
    else
      ServiceResponse.error(payload: {purchase_order:})
    end
  end
end
