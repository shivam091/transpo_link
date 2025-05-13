# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehousesController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_warehouse, only: [:edit, :update, :show, :destroy]

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
    add_breadcrumb t(".breadcrumb"), new_warehouse_path
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
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /warehouses/:id/edit
  def edit
    add_breadcrumb t(".breadcrumb", reference_code: @warehouse.reference_code), edit_warehouse_path(@warehouse)
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
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
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
      :unit_id,
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

  def set_warehouse
    @warehouse ||= Warehouse.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb t("warehouses.breadcrumb"), warehouses_path
  end

  def form_frame_id
    action_name == "create" ? :new_warehouse_form_frame : :edit_warehouse_form_frame
  end

  def form_partial
    "warehouses/form"
  end
end
