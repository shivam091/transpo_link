# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class StockAdjustmentsController < ApplicationController
  before_action :set_adjustable

  # GET /adjustable/:adjustable_id/stock-adjustments/new
  def new
    @stock_adjustment = @adjustable.stock_adjustments.build
  end

  # POST /adjustable/:adjustable_id/stock-adjustments
  def create
    response = StockAdjustments::CreateService.(@adjustable, stock_adjustment_params)

    response.on_success do
      set_flash_message(:notice, :success)

      redirect_back fallback_location: inventories_path, status: :see_other
    end.on_error do
      @stock_adjustment = response.payload[:stock_adjustment]

      respond_to do |format|
        format.turbo_stream do
          set_flash_message(:alert, :error, immediate: true)

          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_adjustable
    @adjustable = if params[:inventory_batch_id]
      InventoryBatch.find(params[:inventory_batch_id])
    else
      Inventory.find(params[:inventory_id])
    end
  end

  def stock_adjustment_params
    params.require(:stock_adjustment).permit(
      :adjustment_reason,
      :adjustment_type,
      :adjusted_quantity,
      :unit_id,
      :note
    ).merge(user: current_user)
  end

  def form_frame_id
    :new_stock_adjustment_form_frame
  end

  def form_partial
    "stock_adjustments/form"
  end
end
