# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductsController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_product, only: [:edit, :update, :show, :destroy]

  # GET /products
  def index
    @products = case params[:status]
                when "active"   then Product.active
                when "inactive" then Product.inactive
                else                 Product.all
                end
    @products, @pagination_metadata = @products.paginate(page: params[:page])
  end

  # GET /products/new
  def new
    add_breadcrumb t(".breadcrumb"), new_product_path
    @product = Product.new
  end

  # POST /products
  def create
    response = Products::CreateService.(product_params)
    @product = response.payload[:product]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_to products_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /products/:id/edit
  def edit
    add_breadcrumb t(".breadcrumb", reference_code: @product.reference_code), edit_product_path(@product)
  end

  # PUT|PATCH /products/:id
  def update
    response = Products::UpdateService.(@product, product_params)
    @product = response.payload[:product]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_to products_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /products/:id
  def show
    add_breadcrumb @product.reference_code, product_path(@product)

    @product_prices = @product.product_prices
  end

  # DELETE /products/:id
  def destroy
    response = Products::DestroyService.(@product)
    @product = response.payload[:product]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_to products_path, status: :see_other
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :sku,
      :description,
      :barcode,
      :min_stock_threshold,
      :unit_id,
      :currency,
      :cost_price,
      :product_category_id,
      :is_active,
      product_prices_attributes: [
        :id,
        :_destroy,
        :warehouse_id,
        :min_quantity,
        :unit_id,
        :unit_price,
        :currency,
        :effective_from,
        :effective_until
      ]
    )
  end

  def set_product
    @product ||= Product.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb t("products.breadcrumb"), products_path
  end

  def form_frame_id
    action_name == "create" ? :new_product_form_frame : :edit_product_form_frame
  end

  def form_partial
    "products/form"
  end
end
