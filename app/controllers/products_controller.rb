# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductsController < ApplicationController

  # GET /products
  def index
    @products = case params[:status]
                when "active"   then Product.active
                when "inactive" then Product.inactive
                else                 Product.all
                end
    @products, @pagination_metadata = @products.paginate(page: params[:page])
  end
end
