# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::Stocks::CreateService < ApplicationService
  def initialize(inventory_batch)
    @inventory_batch = inventory_batch
  end

  def call
    create_stock
  end

  private

  attr_reader :inventory_batch

  def create_stock
    InventoryBatch::Stock.create!(inventory_batch:)
  end
end
