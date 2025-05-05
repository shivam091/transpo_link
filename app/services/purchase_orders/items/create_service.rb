# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::Items::CreateService < ApplicationService
  def initialize(purchase_order, purchase_order_item_attributes)
    @purchase_order, @purchase_order_item_attributes = purchase_order, purchase_order_item_attributes
  end

  def call
    create_purchase_order_item
  end

  private

  attr_reader :purchase_order, :purchase_order_item_attributes

  def create_purchase_order_item
    purchase_order_item = purchase_order.items.build(purchase_order_item_attributes)

    if purchase_order_item.save
      ServiceResponse.success(payload: {purchase_order_item:})
    else
      ServiceResponse.error(payload: {purchase_order_item:})
    end
  end
end
