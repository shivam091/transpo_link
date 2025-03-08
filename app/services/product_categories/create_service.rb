# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductCategories::CreateService < ApplicationService
  def initialize(product_category_attributes)
    @product_category_attributes = product_category_attributes
  end

  def call
    create_product_category
  end

  private

  attr_reader :product_category_attributes

  def create_product_category
    product_category = ProductCategory.new(product_category_attributes)

    if product_category.save
      ServiceResponse.success(payload: {product_category:})
    else
      ServiceResponse.error(payload: {product_category:})
    end
  end
end
