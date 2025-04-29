# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItemsController < ApplicationController
  before_action :find_purchase_order
  before_action :find_purchase_order_item, except: [:index, :new, :create]

  # GET /purchase-orders/:purchase_order_id/purchase-order-items
  def index
    @purchase_order_items = @purchase_order.purchase_order_items

    render partial: "purchase_order_items/list"
  end

  # GET /purchase-orders/:purchase_order_id/purchase-order-items/new
  def new
    @purchase_order_item = @purchase_order.purchase_order_items.build
  end

  # POST /purchase-orders/:purchase_order_id/purchase-order-items
  def create
    response = PurchaseOrderItems::CreateService.(@purchase_order, purchase_order_item_params)
    @purchase_order_item = response.payload[:purchase_order_item]

    respond_to do |format|
      format.turbo_stream do
        if response.success?
          set_flash_message(:notice, :success, immediate: true)

          render turbo_stream: [refresh_items_frame, clear_frame(:remote_modal), render_flash], status: :ok
        else
          set_flash_message(:alert, :error, immediate: true)

          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /purchase-orders/:purchase_order_id/purchase-order-items/:id/edit
  def edit
  end

  # PUT|PATCH /purchase-orders/:purchase_order_id/purchase-order-items/:id
  def update
    response = PurchaseOrderItems::UpdateService.(@purchase_order_item, purchase_order_item_params)
    @purchase_order_item = response.payload[:purchase_order_item]

    respond_to do |format|
      format.turbo_stream do
        if response.success?
          set_flash_message(:notice, :success, immediate: true)

          render turbo_stream: [refresh_items_frame, clear_frame(:remote_modal), render_flash], status: :ok
        else
          set_flash_message(:alert, :error, immediate: true)

          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /purchase-orders/:purchase_order_id/purchase-order-items/:id
  def show
  end

  # DELETE /purchase-orders/:purchase_order_id/purchase-order-items/:id
  def destroy
    response = PurchaseOrderItems::DestroyService.(@purchase_order_item)
    @purchase_order_item = response.payload[:purchase_order_item]

    respond_to do |format|
      format.turbo_stream do
        if response.success?
          set_flash_message(:info, :success, immediate: true)

          render turbo_stream: [refresh_items_frame, render_flash], status: :ok
        else
          set_flash_message(:alert, :error, immediate: true)

          render turbo_stream: render_flash, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH /purchase-orders/:purchase_order_id/purchase-order-items/:id/cancel
  def cancel
    response = PurchaseOrderItems::CancelService.(@purchase_order_item)
    @purchase_order_item = response.payload[:purchase_order_item]

    respond_to do |format|
      format.turbo_stream do
        if response.success?
          set_flash_message(:info, :success, immediate: true)

          render turbo_stream: [refresh_items_frame, render_flash], status: :ok
        else
          set_flash_message(:alert, :error, immediate: true)

          render turbo_stream: render_flash, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def find_purchase_order
    @purchase_order ||= PurchaseOrder.find(params[:purchase_order_id])
  end

  def find_purchase_order_item
    @purchase_order_item ||= @purchase_order.purchase_order_items.find(params[:id])
  end

  def purchase_order_item_params
    params.require(:purchase_order_item).permit(:product_id, :quantity, :unit_id)
  end

  def refresh_items_frame
    turbo_stream.update(view_context.dom_id(@purchase_order, :items), template: "purchase_order_items/index")
  end

  def form_frame_id
    action_name == "create" ? :new_purchase_order_item_form_frame : :edit_purchase_order_item_form_frame
  end

  def form_partial
    "purchase_order_items/form/modal_view"
  end
end
