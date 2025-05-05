# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::CreateService < ApplicationService
  def initialize(inventory, inventory_batch_attributes)
    @inventory = inventory
    @inventory_batch_attributes = inventory_batch_attributes
  end

  def call
    create_inventory_batch
  end

  private

  attr_reader :inventory, :inventory_batch_attributes

  def create_inventory_batch
    inventory_batch = inventory.batches.build(inventory_batch_attributes)

    if inventory_batch.save
      ServiceResponse.success(payload: {inventory_batch:})
    else
      ServiceResponse.error(payload: {inventory_batch:})
    end
  end
end
