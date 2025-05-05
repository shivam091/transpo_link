# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory::BatchesController < ApplicationController
  before_action :find_inventory

  # GET /inventory/:inventory_id/inventory-batches
  def index
    @batches = @inventory.batches

    render partial: "inventories/batches/list"
  end

  private

  def find_inventory
    @inventory ||= Inventory.find(params[:inventory_id])
  end
end
