# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::InventoryBatches::StockAdjustmentsController < ApplicationController
  before_action :set_inventory_batch

  # GET /inventory-batches/:inventory_batch_id/stock-adjustments/new
  def new
    @stock_adjustment = @inventory_batch.stock_adjustments.build
  end

  # POST /inventory-batches/:inventory_batch_id/stock-adjustments
  def create
    response = StockAdjustments::CreateService.(@inventory_batch, stock_adjustment_params)

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

  def set_inventory_batch
    @inventory_batch = InventoryBatch.find(params[:inventory_batch_id])
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
    "inventories/inventory_batches/stock_adjustments/form"
  end
end
