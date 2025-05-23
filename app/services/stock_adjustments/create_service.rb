# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class StockAdjustments::CreateService < ApplicationService
  def initialize(adjustable, stock_adjustment_attributes)
    @adjustable = adjustable
    @stock_adjustment_attributes = stock_adjustment_attributes
  end

  def call
    create_stock_adjustment
  end

  private

  attr_reader :adjustable, :stock_adjustment_attributes

  def create_stock_adjustment
    stock_adjustment = adjustable.stock_adjustments.build(stock_adjustment_attributes)

    if stock_adjustment.save
      ServiceResponse.success(payload: {stock_adjustment:})
    else
      ServiceResponse.error(payload: {stock_adjustment:})
    end
  end
end
