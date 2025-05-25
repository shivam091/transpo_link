# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::Restock::CreateService < ApplicationService
  def initialize(inventory_batch, restock_attributes)
    @inventory_batch, @restock_attributes = inventory_batch, restock_attributes
  end

  def call
    create_inventory_restock
  end

  private

  attr_reader :inventory_batch, :restock_attributes

  def create_inventory_restock
    restock = inventory_batch.restocks.build(restock_attributes)

    if restock.save
      ServiceResponse.success(payload: {restock:})
    else
      ServiceResponse.error(payload: {restock:})
    end
  end
end
