# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::StockAdjustments::CreateService < ApplicationService
  def initialize(inventory_batch, stock_adjustment_attributes)
    @inventory_batch = inventory_batch
    @stock_adjustment_attributes = stock_adjustment_attributes
  end

  def call
    create_stock_adjustment
  end

  private

  attr_reader :inventory_batch, :stock_adjustment_attributes

  def create_stock_adjustment
    stock_adjustment = inventory_batch.stock_adjustments.build(stock_adjustment_attributes)
    debugger
    if stock_adjustment.save
      ServiceResponse.success(payload: {stock_adjustment:})
    else
      ServiceResponse.error(payload: {stock_adjustment:})
    end
  end
end
