# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::UpdateAverageCostPriceService < ApplicationService
  def initialize(inventory)
    @inventory = inventory
  end

  def call
    update_average_cost_price
  end

  private

  attr_reader :inventory

  # Updates the average cost price based on the weighted average formula:
  #
  # Average Cost Price = (Sum of (Batch Cost Price * Batch Quantity)) / (Total Quantity in Batches)
  #
  # Formula breakdown:
  # - total_cost = Σ (batch.cost_price * batch.quantity)
  # - total_quantity = Σ batch.quantity
  # - average_cost_price = total_cost / total_quantity (if total_quantity > 0, else 0)
  #
  # Example:
  # Batch 1: 100 units @ $10 → Total: $1000
  # Batch 2: 200 units @ $12 → Total: $2400
  # Batch 3: 150 units @ $11 → Total: $1650
  #
  # New Average Cost Price = (1000 + 2400 + 1650) / (100 + 200 + 150) = 11.22
  #
  def update_average_cost_price
    batches_table = Inventory::Batch.arel_table

    total_cost_expr = TranspoLink::SqlFunctions.sum_mul(batches_table[:cost_price], batches_table[:quantity])
    total_quantity_expr = TranspoLink::SqlFunctions.sum(batches_table[:quantity])

    totals = inventory.batches.pick(total_cost_expr, total_quantity_expr)

    total_cost, total_quantity = totals.map(&:to_f)

    average_cost_price = total_quantity.positive? ? (total_cost / total_quantity) : 0.0

    inventory.update!(average_cost_price: average_cost_price)
  end
end
