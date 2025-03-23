# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehousesController < ApplicationController
  add_breadcrumb :warehouses, :warehouses_path

  before_action :find_warehouse, only: [:edit, :update, :show, :destroy]

  # GET /warehouses
  def index
    @warehouses = case params[:status]
                  when "active"   then Warehouse.active
                  when "inactive" then Warehouse.inactive
                  else                 Warehouse.all
                  end
    @warehouses, @pagination_metadata = @warehouses.paginate(page: params[:page])
  end

  # GET /warehouses/new
  def new
    add_breadcrumb :new_warehouse, new_warehouse_path
    @warehouse = Warehouse.new
  end

  # POST /warehouses
  def create
    response = Warehouses::CreateService.(warehouse_params)
    @warehouse = response.payload[:warehouse]

    if response.success?
      set_flash_message(:notice, :success)
      redirect_to warehouses_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:new_warehouse_form_frame, partial: "warehouses/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /warehouses/:id/edit
  def edit
    add_breadcrumb :edit_warehouse, edit_warehouse_path(@warehouse), reference_code: @warehouse.reference_code
  end

  # PUT|PATCH /warehouses/:id
  def update
    response = Warehouses::UpdateService.(@warehouse, warehouse_params)
    @warehouse = response.payload[:warehouse]

    if response.success?
      set_flash_message(:notice, :success)
      redirect_to warehouses_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:edit_warehouse_form_frame, partial: "warehouses/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /warehouses/:id
  def show
    add_breadcrumb @warehouse.reference_code, warehouse_path(@warehouse)
  end

  # DELETE /warehouses/:id
  def destroy
    response = Warehouses::DestroyService.(@warehouse)
    @warehouse = response.payload[:warehouse]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end
    redirect_to warehouses_path, status: :see_other
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
      :is_active,
      manager_ids: [],
      supplier_ids: [],
      address_attributes: [
        :address1,
        :address2,
        :city,
        :state,
        :country,
        :postal_code
      ]
    )
  end

  def find_warehouse
    @warehouse ||= Warehouse.find(params[:id])
  end
end
