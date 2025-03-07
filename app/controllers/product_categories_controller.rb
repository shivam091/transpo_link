# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductCategoriesController < ApplicationController

  # GET /product-categories
  def index
    @product_categories = ProductCategory.includes(:parent_category)
    @product_categories, @pagination_metadata = @product_categories.paginate(page: params[:page])
  end

  # GET /product-categories/new
  def new
    @product_category = ProductCategory.new
  end

  # POST /product-categories
  def create
    response = ProductCategories::CreateService.(product_category_params)
    @product_category = response.payload[:product_category]
    if response.success?
      flash[:notice] = response.message
      redirect_to product_categories_path, status: :see_other
    else
      flash.now[:alert] = response.message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:new_product_category_form_frame, partial: "product_categories/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def product_category_params
    params.require(:product_category).permit(:name, :parent_category_id, :is_active)
  end
end
