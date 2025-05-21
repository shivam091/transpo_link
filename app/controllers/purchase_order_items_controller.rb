# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItemsController < ApplicationController
  before_action :set_purchase_order, only: [:index, :new, :create]
  before_action :set_purchase_order_item, except: [:index, :new, :create]

  requires_authorization_for :index, :purchase_order_items, :view_all
  requires_authorization_for [:new, :create], :purchase_order_items, :create
  requires_authorization_for [:edit, :update], :purchase_order_items, :update
  requires_authorization_for :show, :purchase_order_items, :view
  requires_authorization_for :destroy, :purchase_order_items, :delete
  requires_authorization_for :cancel, :purchase_order_items, :cancel

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

    if response.success?
      set_flash_message(:notice, :success)

      redirect_back fallback_location: purchase_orders_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /purchase-order-items/:id/edit
  def edit
  end

  # PUT|PATCH /purchase-order-items/:id
  def update
    response = PurchaseOrderItems::UpdateService.(@purchase_order_item, purchase_order_item_params)
    @purchase_order_item = response.payload[:purchase_order_item]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_back fallback_location: purchase_orders_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /purchase-order-items/:id
  def show
  end

  # DELETE /purchase-order-items/:id
  def destroy
    response = PurchaseOrderItems::DestroyService.(@purchase_order_item)
    @purchase_order_item = response.payload[:purchase_order_item]

    if response.success?
      set_flash_message(:notice, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_back fallback_location: purchase_orders_path, status: :see_other
  end

  # PATCH /purchase-order-items/:id/cancel
  def cancel
    response = PurchaseOrderItems::CancelService.(@purchase_order_item)
    @purchase_order_item = response.payload[:purchase_order_item]

    if response.success?
      set_flash_message(:notice, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_back fallback_location: purchase_orders_path, status: :see_other
  end

  private

  def set_purchase_order
    @purchase_order ||= PurchaseOrder.find(params[:purchase_order_id])
  end

  def set_purchase_order_item
    @purchase_order_item ||= PurchaseOrderItem.find(params[:id])
  end

  def purchase_order_item_params
    params.require(:purchase_order_item).permit(:product_id, :quantity, :unit_id)
  end

  def form_frame_id
    action_name == "create" ? :new_purchase_order_item_form_frame : :edit_purchase_order_item_form_frame
  end

  def form_partial
    "purchase_order_items/form/modal_view"
  end
end
