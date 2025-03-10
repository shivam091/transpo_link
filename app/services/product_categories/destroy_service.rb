# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductCategories::DestroyService < ApplicationService
  def initialize(product_category)
    @product_category = product_category
  end

  def call
    destroy_product_category
  end

  private

  attr_reader :product_category

  def destroy_product_category
    if product_category.destroy
      ServiceResponse.success(payload: {product_category:})
    else
      ServiceResponse.error(payload: {product_category:})
    end
  end
end
