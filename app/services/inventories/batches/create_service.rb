# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::Batches::CreateService < ApplicationService
  def initialize(inventory, batch_attributes)
    @inventory = inventory
    @batch_attributes = batch_attributes
  end

  def call
    create_batch
  end

  private

  attr_reader :inventory, :batch_attributes

  def create_batch
    batch = inventory.batches.build(batch_attributes)

    if batch.save
      ServiceResponse.success(payload: {batch:})
    else
      ServiceResponse.error(payload: {batch:})
    end
  end
end
