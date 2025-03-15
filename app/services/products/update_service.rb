# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Products::UpdateService < ApplicationService
  def initialize(product, product_attributes)
    @product, @product_attributes = product, product_attributes
  end

  def call
    update_product
  end

  private

  attr_reader :product, :product_attributes

  def update_product
    if product.update(product_attributes)
      ServiceResponse.success(payload: {product:})
    else
      ServiceResponse.error(payload: {product:})
    end
  end
end
