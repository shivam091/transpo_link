# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::Stocks::UpdateService < ApplicationService
  def initialize(inventory_batch, stock_attributes)
    @inventory_batch = inventory_batch
    @stock_attributes = stock_attributes
  end

  def call
    update_stock
  end

  private

  attr_reader :inventory_batch, :stock_attributes

  def update_stock
    inventory_batch.stock.update!(stock_attributes)
  end
end
