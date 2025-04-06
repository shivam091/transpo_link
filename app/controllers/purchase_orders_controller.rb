# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrdersController < ApplicationController
  before_action :set_breadcrumbs, :fetch_accessible_purchase_orders
  before_action :find_purchase_order, except: [:index, :new, :create]

  # GET /purchase-orders
  def index
    @purchase_orders, @pagination_metadata = @purchase_orders.paginate(page: params[:page])
  end

  # GET /purchase-orders/new
  def new
    add_breadcrumb t(".breadcrumb"), new_purchase_order_path
    @purchase_order = PurchaseOrder.new
  end

  # POST /purchase-orders
  def create
    response = PurchaseOrders::CreateService.(current_user, purchase_order_params)
    @purchase_order = response.payload[:purchase_order]

    if response.success?
      set_flash_message(:notice, :success)
      redirect_to purchase_orders_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:new_purchase_order_form_frame, partial: "purchase_orders/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /purchase-orders/:id/edit
  def edit
    add_breadcrumb t(".breadcrumb", reference_code: @purchase_order.reference_code), edit_purchase_order_path(@purchase_order)
  end

  # PUT|PATCH /purchase-orders/:id
  def update
    response = PurchaseOrders::UpdateService.(@purchase_order, purchase_order_params)
    @purchase_order = response.payload[:purchase_order]

    if response.success?
      set_flash_message(:notice, :success)
      redirect_to purchase_orders_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:edit_purchase_order_form_frame, partial: "purchase_orders/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /purchase-orders/:id
  def show
    add_breadcrumb @purchase_order.reference_code, purchase_order_path(@purchase_order)
  end

  # DELETE /purchase-orders/:id
  def destroy
    response = PurchaseOrders::DestroyService.(@purchase_order)
    @purchase_order = response.payload[:purchase_order]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to purchase_orders_path, status: :see_other
  end

  # PATCH /purchase-orders/:id/cancel
  def cancel
    response = PurchaseOrders::CancelService.(@purchase_order)
    @purchase_order = response.payload[:purchase_order]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to purchase_orders_path, status: :see_other
  end

  # PATCH /purchase-orders/:id/submit
  def submit
    response = PurchaseOrders::SubmitService.(@purchase_order)
    @purchase_order = response.payload[:purchase_order]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to purchase_orders_path, status: :see_other
  end

  # PATCH /purchase-orders/:id/approve
  def approve
    response = PurchaseOrders::ApproveService.(@purchase_order)
    @purchase_order = response.payload[:purchase_order]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to purchase_orders_path, status: :see_other
  end

  # PATCH /purchase-orders/:id/reject
  def reject
    response = PurchaseOrders::RejectService.(@purchase_order)
    @purchase_order = response.payload[:purchase_order]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to purchase_orders_path, status: :see_other
  end

  private

  def purchase_order_params
    params.require(:purchase_order).permit(
      :warehouse_id,
      :supplier_id,
      :notes,
      purchase_order_items_attributes: [
        :id,
        :_destroy,
        :product_id,
        :quantity,
        :uom
      ]
    )
  end

  def fetch_accessible_purchase_orders
    @purchase_orders ||= PurchaseOrder.accessible(current_user)
  end

  def set_breadcrumbs
    add_breadcrumb t("purchase_orders.breadcrumb"), purchase_orders_path
  end

  def find_purchase_order
    @purchase_order ||= @purchase_orders.find(params[:id])
  end
end
