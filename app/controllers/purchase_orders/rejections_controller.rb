# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::RejectionsController < ApplicationController
  before_action :set_purchase_order

  requires_authorization :purchase_orders, :reject

  # GET /purchase-orders/:purchase_order_id/rejection/new
  def new
    @rejection = @purchase_order.build_rejection
  end

  # POST /purchase-orders/:purchase_order_id/rejection
  def create
    response = PurchaseOrders::Rejection::CreateService.(@purchase_order, rejection_params)

    response.on_success do
      set_flash_message(:notice, :success)

      redirect_back fallback_location: purchase_orders_path, status: :see_other
    end.on_error do
      @rejection = response.payload[:rejection]

      respond_to do |format|
        format.turbo_stream do
          set_flash_message(:alert, :error, immediate: true)

          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_purchase_order
    @purchase_order ||= PurchaseOrder.find(params[:purchase_order_id])
  end

  def rejection_params
    params.require(:rejection).permit(
      :reason,
      :suggested_alternatives,
      :note,
    ).merge(user: current_user)
  end

  def form_frame_id
    :po_rejection_confirmation_form_frame
  end

  def form_partial
    "purchase_orders/rejections/form"
  end
end
