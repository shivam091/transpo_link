# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::Batches::UpsertService < ApplicationService
  def initialize(inventory, batch_attributes)
    @inventory = inventory
    @batch_attributes = batch_attributes.dup.tap do |attrs|
      attrs[:expiration_date] = attrs[:expiration_date].presence
    end
  end

  def call
    create_or_merge_batch
  end

  private

  attr_reader :inventory, :batch_attributes

  def create_or_merge_batch
    batch = inventory.batches.by_batch_number_and_expiry(
      *batch_attributes.values_at(:batch_number, :expiration_date)
    ).first

    if batch
      Inventories::Batches::MergeService.(batch, batch_attributes)
    else
      Inventories::Batches::CreateService.(inventory, batch_attributes)
    end
  end
end
