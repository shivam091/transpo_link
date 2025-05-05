# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::BatchesController < ApplicationController
  before_action :set_inventory

  # GET /inventories/:inventory_id/batches
  def index
    @batches = @inventory.batches

    render partial: "inventories/batches/list"
  end

  private

  def set_inventory
    @inventory ||= Inventory.find(params[:inventory_id])
  end
end
