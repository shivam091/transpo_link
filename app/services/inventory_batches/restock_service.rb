# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::RestockService < ApplicationService
  def initialize(inventory_batch, restock)
    @inventory_batch, @restock = inventory_batch, restock
  end

  def call
    restock_inventory
  end

  private

  attr_reader :inventory_batch, :restock

  def restock_inventory
    inventory = inventory_batch.inventory

    restock_attributes = {
      quantity: restock.quantity,
      unit: restock.unit,
      unit_cost: inventory_batch.cost_price,
      total_cost: inventory_batch.source.total_cost,
      currency: inventory_batch.currency
    }

    inventory_movement = InventoryMovements::RestockService.(inventory, restock, restock_attributes).payload[:inventory_movement]

    inventory_stock_attributes = {
      quantity_in_hand: inventory_movement.quantity
    }
    batch_stock_attributes = {
      restocked_quantity: inventory_batch.restocked_quantity + inventory_movement.quantity
    }

    Stocks::UpdateService.(inventory, inventory_stock_attributes, :increment)

    InventoryBatches::Stocks::UpdateService.(inventory_batch, batch_stock_attributes)
  end
end
