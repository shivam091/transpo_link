# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::SubmitService < ApplicationService
  def initialize(purchase_order)
    @purchase_order = purchase_order
  end

  def call
    submit_purchase_order
  end

  private

  attr_reader :purchase_order

  def submit_purchase_order
    if purchase_order.may_submit? && purchase_order.submit!
      ServiceResponse.success(payload: {purchase_order:})
    else
      ServiceResponse.error(payload: {purchase_order:})
    end
  end
end
