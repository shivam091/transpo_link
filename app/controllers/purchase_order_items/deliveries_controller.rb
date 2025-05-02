# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::DeliveriesController < ApplicationController
  before_action :find_purchase_order, :find_purchase_order_item

  # GET /purchase-orders/:purchase_order_id/purchase-order-items/:purchase_order_item_id/delivery/new
  def new
    @delivery = @purchase_order_item.deliveries.build
  end

  # POST /purchase-orders/:purchase_order_id/purchase-order-items/:purchase_order_item_id/delivery
  def create
    response = PurchaseOrderItems::Deliveries::CreateService.(@purchase_order_item, delivery_params)
    @delivery = response.payload[:delivery]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_back fallback_location: purchase_orders_path, status: :see_other
    else
      respond_to do |format|
        format.turbo_stream do
          set_flash_message(:alert, :error, immediate: true)

          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def find_purchase_order
    @purchase_order ||= PurchaseOrder.find(params[:purchase_order_id])
  end

  def find_purchase_order_item
    @purchase_order_item ||= @purchase_order.purchase_order_items.find(params[:purchase_order_item_id])
  end

  def delivery_params
    params.require(:delivery).permit(:quantity, :unit_id)
  end

  def form_frame_id
    :new_purchase_order_item_delivery_form_frame
  end

  def form_partial
    "purchase_order_items/deliveries/form"
  end
end
