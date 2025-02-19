# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehousesController < ApplicationController

  # GET /warehouses
  def index
    @warehouses = Warehouse.all
    @warehouses, @pagination_data = @warehouses.paginate(page: params[:page])
  end
end
