# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductCategories::UpdateService < ApplicationService
  def initialize(product_category, product_category_attributes)
    @product_category = product_category
    @product_category_attributes = product_category_attributes
  end

  def call
    update_product_category
  end

  private

  attr_reader :product_category, :product_category_attributes

  def update_product_category
    if product_category.update(product_category_attributes)
      ServiceResponse.success(payload: {product_category:})
    else
      ServiceResponse.error(payload: {product_category:})
    end
  end
end
