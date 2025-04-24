# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::MergeService < ApplicationService
  def initialize(inventory_batch, inventory_batch_attributes)
    @inventory_batch = inventory_batch
    @inventory_batch_attributes = inventory_batch_attributes
  end

  def call
    merge_inventory_batch
  end

  private

  attr_reader :inventory_batch, :inventory_batch_attributes

  def merge_inventory_batch
    quantity, source_unit = inventory_batch_attributes.values_at(:quantity, :unit)

    # Considered target unit as `inventory_batch.unit` because inventory unit is set
    # to batch at the time of creation via InventoryBatch#convert_to_inventory_unit.
    converted_quantity = UnitConversion.convert(source_unit, inventory_batch.unit, quantity)
    inventory_batch.quantity += converted_quantity

    if inventory_batch.save
      ServiceResponse.success(payload: {inventory_batch:})
    else
      ServiceResponse.error(payload: {inventory_batch:})
    end
  end
end
