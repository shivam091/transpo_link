# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Products::ProductPrices::DestroyService < ApplicationService
  def initialize(product_price)
    @product_price = product_price
  end

  def call
    destroy_product_price
  end

  private

  attr_reader :product_price

  def destroy_product_price
    if product_price.destroy
      ServiceResponse.success(payload: {product_price:})
    else
      ServiceResponse.error(payload: {product_price:})
    end
  end
end
