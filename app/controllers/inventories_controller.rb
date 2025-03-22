# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoriesController < ApplicationController

  # GET /inventories
  def index
    @inventories = Inventory.all
    @inventories, @pagination_metadata = @inventories.paginate(page: params[:page])
  end

  # GET /inventories/new
  def new
    @inventory = Inventory.new
  end

  # POST /inventories
  def create
    response = Inventories::CreateService.(inventory_params)
    @inventory = response.payload[:inventory]

    if response.success?
      set_flash_message(:notice, :success)
      redirect_to inventories_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:new_inventory_form_frame, partial: "inventories/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def inventory_params
    params.require(:inventory).permit(
      :product_id,
      :warehouse_id,
      :batch_number,
      :cost_price,
      :expiration_date,
      :currency,
      :inventory_unit,
      :tracking_method
    )
  end

end
