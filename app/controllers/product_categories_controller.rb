# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductCategoriesController < ApplicationController

  # GET /product-categories
  def index
    @product_categories = ProductCategory.all
    @product_categories, @pagination_metadata = @product_categories.paginate(page: params[:page])
  end
end
