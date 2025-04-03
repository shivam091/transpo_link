# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrdersController < ApplicationController
  before_action :set_breadcrumbs, :fetch_accessible_purchase_orders

  # GET /purchase-orders
  def index
    @purchase_orders, @pagination_metadata = @purchase_orders.paginate(page: params[:page])
  end

  private

  def fetch_accessible_purchase_orders
    @purchase_orders ||= PurchaseOrder.accessible(current_user)
  end

  def set_breadcrumbs
    add_breadcrumb t("purchase_orders.breadcrumb"), purchase_orders_path
  end
end
