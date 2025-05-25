# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::RestocksController < ApplicationController
  before_action :set_inventory_batch

  requires_authorization :inventories, :restock

  # GET /inventory-batches/:inventory_batch_id/restocks/new
  def new
    @restock = @inventory_batch.restocks.build
  end

  # POST /inventory-batches/:inventory_batch_id/restocks
  def create
    response = Inventories::Restock::CreateService.(@inventory_batch, restock_params)

    response.on_success do
      set_flash_message(:notice, :success)

      redirect_back fallback_location: inventories_path, status: :see_other
    end.on_error do
      @restock = response.payload[:restock]

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
    @inventory_batch ||= InventoryBatch.find(params[:inventory_batch_id])
  end

  def restock_params
    params.require(:restock).permit(
      :quantity,
      :unit_id,
      :comment,
      :note
    ).merge(user: current_user)
  end

  def form_frame_id
    :inventory_batch_restock_form_frame
  end

  def form_partial
    "inventory_batches/restocks/form"
  end
end
