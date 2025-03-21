# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoriesController < ApplicationController

  # GET /inventories
  def index
    @inventories = Inventory.all
    @inventories, @pagination_metadata = @inventories.paginate(page: params[:page])
  end
end
