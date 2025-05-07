# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::InventoryBatchesController < ApplicationController
  before_action :find_inventory

  # GET /inventories/:inventory_id/inventory-batches
  def index
    @inventory_batches = @inventory.inventory_batches

    render partial: "inventories/inventory_batches/list"
  end

  private

  def find_inventory
    @inventory ||= Inventory.find(params[:inventory_id])
  end
end
