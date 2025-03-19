# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Products::CreateService < ApplicationService
  def initialize(product_attributes)
    @product_attributes = product_attributes
  end

  def call
    create_product
  end

  private

  attr_reader :product_attributes

  def create_product
    product = Product.new(product_attributes)

    if product.save
      ServiceResponse.success(payload: {product:})
    else
      ServiceResponse.error(payload: {product:})
    end
  end
end
