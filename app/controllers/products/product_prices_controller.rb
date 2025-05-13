# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Products::ProductPricesController < ApplicationController
  before_action :set_product
  before_action :set_product_price, except: [:new, :create]

  # GET /products/:product_id/product-prices/new
  def new
    @product_price = @product.product_prices.build
  end

  # POST /products/:product_id/product-prices
  def create
    response = Products::ProductPrices::CreateService.(@product, product_price_params)
    @product_price = response.payload[:product_price]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_back fallback_location: @product, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # GET /products/:product_id/product-prices/:id/edit
  def edit
  end

  # PUT|PATCH /products/:product_id/product-prices/:id
  def update
    response = Products::ProductPrices::UpdateService.(@product_price, product_price_params)
    @product_price = response.payload[:product_price]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_back fallback_location: @product, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /products/:product_id/product-prices/:id
  def destroy
    response = Products::DestroyService.(@product_price)
    @product_price = response.payload[:product_price]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_back fallback_location: @product, status: :see_other
  end

  private

  def set_product
    @product ||= Product.find(params[:product_id])
  end

  def set_product_price
    @product_price ||= @product.product_prices.find(params[:id])
  end

  def product_price_params
    params.require(:product_price).permit(
      :warehouse_id,
      :min_quantity,
      :unit_id,
      :unit_price,
      :currency,
      :effective_from,
      :effective_until
    )
  end

  def form_frame_id
    action_name == "create" ? :new_product_price_form_frame : :edit_product_price_form_frame
  end

  def form_partial
    "products/product_prices/form/modal_view"
  end
end
