# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoriesController < ApplicationController
  before_action :set_breadcrumbs
  before_action :find_inventory, except: [:index, :new, :create]

  # GET /inventories
  def index
    @inventories = Inventory.all
    @inventories, @pagination_metadata = @inventories.paginate(page: params[:page])
  end

  # GET /inventories/new
  def new
    add_breadcrumb t(".breadcrumb"), new_inventory_path
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

  # GET /inventories/:id/edit
  def edit
    add_breadcrumb t(".breadcrumb", reference_code: @inventory.reference_code), edit_inventory_path(@inventory)
  end

  # PUT|PATCH /inventories/:id
  def update
    response = Inventories::UpdateService.(@inventory, inventory_params)
    @inventory = response.payload[:inventory]

    if response.success?
      set_flash_message(:notice, :success)
      redirect_to inventories_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:edit_inventory_form_frame, partial: "inventories/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /inventories/:id
  def show
    add_breadcrumb @inventory.reference_code, inventory_path(@inventory)

    @inventory_batches = @inventory.inventory_batches.includes(:unit, :stock)
    @inventory_movements = @inventory.inventory_movements.includes(:unit)
    @inventory_audit_logs = @inventory.inventory_audit_logs.includes(user: [:user_detail])
  end

  private

  def inventory_params
    params.require(:inventory).permit(
      :product_id,
      :warehouse_id,
      :tracking_method,
      :unit_id,
      :average_cost_price,
      :currency,
      :low_stock_threshold,
    )
  end

  def find_inventory
    @inventory ||= Inventory.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb t("inventories.breadcrumb"), inventories_path
  end
end
