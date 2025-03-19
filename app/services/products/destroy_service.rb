# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Products::DestroyService < ApplicationService
  def initialize(product)
    @product = product
  end

  def call
    destroy_product
  end

  private

  attr_reader :product

  def destroy_product
    if product.destroy
      ServiceResponse.success(payload: {product:})
    else
      ServiceResponse.error(payload: {product:})
    end
  end
end
