# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::DestroyService < ApplicationService
  def initialize(purchase_order)
    @purchase_order = purchase_order
  end

  def call
    destroy_purchase_order
  end

  private

  attr_reader :purchase_order

  def destroy_purchase_order
    if purchase_order.destroy
      ServiceResponse.success(payload: {purchase_order:})
    else
      ServiceResponse.error(payload: {purchase_order:})
    end
  end
end
