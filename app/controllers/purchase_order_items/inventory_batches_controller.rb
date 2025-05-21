# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::InventoryBatchesController < ApplicationController
  before_action :set_purchase_order_item_and_inventory

  requires_authorization_for [:new, :create], :inventory_batches, :create

  # GET /purchase-order-items/:purchase_order_item_id/inventory-batches/new
  def new
    @inventory_batch = @purchase_order_item.inventory_batches.build
  end

  # GET /purchase-order-items/:purchase_order_item_id/inventory-batches
  def create
    response = InventoryBatches::CreateService.(@inventory, inventory_batch_params)
    @inventory_batch = response.payload[:inventory_batch]

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

  def inventory_batch_params
    params.require(:inventory_batch).permit(
      :batch_number,
      :expiration_date,
      :quantity,
      :unit_id
    ).merge(source: @purchase_order_item)
  end

  def set_purchase_order_item_and_inventory
    @purchase_order_item ||= PurchaseOrderItem.find(params[:purchase_order_item_id])
    @inventory ||= @purchase_order_item.inventory
  end

  def form_frame_id
    :new_inventory_batch_form_frame
  end

  def form_partial
    "purchase_order_items/inventory_batches/form"
  end
end
