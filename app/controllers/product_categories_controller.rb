# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductCategoriesController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_product_category, except: [:index, :new, :create]

  # GET /product-categories
  def index
    @product_categories = ProductCategory.includes(:parent_category)
    @product_categories = case params[:status]
                          when "active"   then @product_categories.active
                          when "inactive" then @product_categories.inactive
                          else                 @product_categories
                          end
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
      set_flash_message(:notice, :success)
      redirect_to product_categories_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
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

  # GET /product-categories/:id/edit
  def edit
  end

  # PUT|PATCH /product-categories/:id
  def update
    response = ProductCategories::UpdateService.(@product_category, product_category_params)
    @product_category = response.payload[:product_category]

    if response.success?
      set_flash_message(:notice, :success)
      redirect_to product_categories_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:edit_product_category_form_frame, partial: "product_categories/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /product-categories/:id
  def destroy
    response = ProductCategories::DestroyService.(@product_category)
    @product_category = response.payload[:product_category]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end
    redirect_to product_categories_path, status: :see_other
  end

  private

  def product_category_params
    params.require(:product_category).permit(:name, :parent_category_id, :is_active)
  end

  def set_product_category
    @product_category ||= ProductCategory.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb t("product_categories.breadcrumb"), product_categories_path
  end
end
