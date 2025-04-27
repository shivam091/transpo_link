# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::DeliveriesController < ApplicationController

  before_action :find_purchase_order, :find_purchase_order_item

  # GET /purchase-orders/:purchase_order_id/purchase-order-items/:purchase_order_item_id/delivery/new
  def new
    @inventory_batch = InventoryBatch.new
  end

  # POST /purchase-orders/:purchase_order_id/purchase-order-items/:purchase_order_item_id/delivery
  def create
    response = PurchaseOrderItems::DeliveryWorkflowService.(@purchase_order_item, inventory_batch_params)
    @inventory_batch = response.payload[:inventory_batch]

    respond_to do |format|
      format.turbo_stream do
        if response.success?
          set_flash_message(:notice, :success)

          render turbo_stream: [refresh_items_frame, clear_frame(:remote_modal), render_flash], status: :ok
        else
          set_flash_message(:alert, :error)

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

  def inventory_batch_params
    params.require(:inventory_batch).permit(
      :batch_number,
      :expiration_date,
      :quantity,
      :unit_id
    ).merge!(
      cost_price: @purchase_order_item.unit_cost,
      currency: @purchase_order_item.currency
    )
  end

  def form_frame_id
    :new_purchase_order_item_delivery_form_frame
  end

  def form_partial
    "purchase_order_items/deliveries/form"
  end

  def refresh_items_frame
    turbo_stream.update(view_context.dom_id(@purchase_order, :items), template: "purchase_order_items/index")
  end
end
