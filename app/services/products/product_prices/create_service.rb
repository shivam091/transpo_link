# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Products::ProductPrices::CreateService < ApplicationService
  def initialize(product, product_price_attributes)
    @product, @product_price_attributes = product, product_price_attributes
  end

  def call
    create_product_price
  end

  private

  attr_reader :product, :product_price_attributes

  def create_product_price
    product_price = product.product_prices.build(product_price_attributes)

    if product_price.save
      ServiceResponse.success(payload: {product_price:})
    else
      ServiceResponse.error(payload: {product_price:})
    end
  end
end
