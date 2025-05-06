# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatches::UpsertService < ApplicationService
  def initialize(inventory, inventory_batch_attributes)
    @inventory = inventory
    @inventory_batch_attributes = inventory_batch_attributes.dup.tap do |attrs|
      attrs[:expiration_date] = attrs[:expiration_date].presence
    end
  end

  def call
    create_or_merge_inventory_batch
  end

  private

  attr_reader :inventory, :inventory_batch_attributes

  def create_or_merge_inventory_batch
    inventory_batch = inventory.inventory_batches.by_batch_number_and_expiry(
      *inventory_batch_attributes.values_at(:batch_number, :expiration_date)
    ).first

    if inventory_batch
      InventoryBatches::MergeService.(inventory_batch, inventory_batch_attributes)
    else
      InventoryBatches::CreateService.(inventory, inventory_batch_attributes)
    end
  end
end
