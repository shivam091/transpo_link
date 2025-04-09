# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItemsController < ApplicationController
  before_action :find_purchase_order

  # GET /purchase-orders/:purchase_order_id/purchase-order-items
  def index
    @purchase_order_items = @purchase_order.purchase_order_items

    render partial: "purchase_order_items/list"
  end

  private

  def find_purchase_order
    @purchase_order ||= PurchaseOrder.find(params[:purchase_order_id])
  end
end
