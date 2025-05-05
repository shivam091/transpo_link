# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::Batches::MergeService < ApplicationService
  def initialize(batch, batch_attributes)
    @batch = batch
    @batch_attributes = batch_attributes
  end

  def call
    merge_batch
  end

  private

  attr_reader :batch, :batch_attributes

  def merge_batch
    quantity, source_unit = batch_attributes.values_at(:quantity, :unit_id)

    if batch.merge_with!(quantity:, source_unit:)
      ServiceResponse.success(payload: {batch:})
    else
      ServiceResponse.error(payload: {batch:})
    end
  end
end
