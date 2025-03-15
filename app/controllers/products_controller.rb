# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductsController < ApplicationController

  before_action :find_product, only: [:edit, :update, :show, :destroy]

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
          render turbo_stream: [
            turbo_stream.update(:new_product_form_frame, partial: "products/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /products/:id/edit
  def edit
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
          render turbo_stream: [
            turbo_stream.update(:edit_product_form_frame, partial: "products/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :sku,
      :description,
      :barcode,
      :min_stock_threshold,
      :capacity_unit,
      :currency,
      :cost_price,
      :product_category_id,
      :is_active,
      unit_conversions_attributes: [
        :id,
        :_destroy,
        :from_unit,
        :to_unit,
        :conversion_rate
      ],
      product_prices_attributes: [
        :id,
        :_destroy,
        :warehouse_id,
        :min_quantity,
        :unit_price,
        :currency
      ]
    )
  end

  def find_product
    @product ||= Product.find(params[:id])
  end
end
