# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Products::ProductPrices::UpdateService < ApplicationService
  def initialize(product_price, product_price_attributes)
    @product_price, @product_price_attributes = product_price, product_price_attributes
  end

  def call
    update_product_price
  end

  private

  attr_reader :product_price, :product_price_attributes

  def update_product_price
    if product_price.update(product_price_attributes)
      ServiceResponse.success(payload: {product_price:})
    else
      ServiceResponse.error(payload: {product_price:})
    end
  end
end
