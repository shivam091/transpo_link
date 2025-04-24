# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::UpsertService < ApplicationService
  def initialize(inventory, inventory_batch_attributes)
    @inventory = inventory
    @inventory_batch_attributes = inventory_batch_attributes
  end

  def call
    InventoryBatch.transaction do
      create_or_merge_inventory_batch
    rescue => exception
      raise ActiveRecord::Rollback
    end
  end

  private

  attr_reader :inventory, :inventory_batch_attributes

  def create_or_merge_inventory_batch
    inventory_batch = inventory.inventory_batches.find_by(
      InventoryBatch.arel_table[:batch_number].eq(inventory_batch_attributes[:batch_number]).and(
        InventoryBatch.arel_table[:expiration_date].eq(inventory_batch_attributes[:expiration_date])
      )
    )

    if inventory_batch
      InventoryBatches::MergeService.(inventory_batch, inventory_batch_attributes)
    else
      InventoryBatches::CreateService.(inventory, inventory_batch_attributes)
    end
  end
end
