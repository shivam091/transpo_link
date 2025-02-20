# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehousesController < ApplicationController

  # GET /warehouses
  def index
    @warehouses = Warehouse.all
    @warehouses, @pagination_data = @warehouses.paginate(page: params[:page])
  end

  # GET /warehouses/new
  def new
    @warehouse = Warehouse.new
  end

  # POST /warehouses
  def create
    response = Warehouses::CreateService.(warehouse_params)
    @warehouse = response.payload[:warehouse]
    if response.success?
      flash[:notice] = response.message
      redirect_to warehouses_path, status: :see_other
    else
      flash.now[:alert] = response.message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:warehouse_form, partial: "warehouses/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def warehouse_params
    params.require(:warehouse).permit(
      :name,
      :email_address,
      :contact_number,
      :description,
      :total_capacity,
      :capacity_unit,
      :latitude,
      :longitude,
      :is_active
    )
  end
end
