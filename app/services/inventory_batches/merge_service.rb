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
    quantity, source_unit = inventory_batch_attributes.values_at(:quantity, :unit_id)

    if inventory_batch.merge_with!(quantity:, source_unit:)
      ServiceResponse.success(payload: {inventory_batch:})
    else
      ServiceResponse.error(payload: {inventory_batch:})
    end
  end
end
