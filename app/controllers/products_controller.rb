# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductsController < ApplicationController

  # GET /products
  def index
    @products = params[:status].present? ? Product.send(params[:status]) : Product.all
    @products, @pagination_metadata = @products.paginate(page: params[:page])
  end
end
