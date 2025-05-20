# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrders::ApprovalsController < ApplicationController
  before_action :set_purchase_order

  # GET /purchase-orders/:purchase_order_id/approval/new
  def new
    @approval = @purchase_order.build_approval
  end

  # POST /purchase-orders/:purchase_order_id/approval
  def create
    response = PurchaseOrders::Approval::CreateService.(@purchase_order, approval_params)

    response.on_success do
      set_flash_message(:notice, :success)

      redirect_back fallback_location: purchase_orders_path, status: :see_other
    end.on_error do
      @approval = response.payload[:approval]

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

  def approval_params
    params.require(:approval).permit(
      :reference_document,
      :expected_delivery_date,
      :remarks,
      :partial_delivery_allowed
    )
  end

  def form_frame_id
    :po_approval_confirmation_form_frame
  end

  def form_partial
    "purchase_orders/approvals/form"
  end
end
