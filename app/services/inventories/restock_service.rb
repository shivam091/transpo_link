# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::RestockService < ApplicationService
  def initialize(inventory, source, restock_attributes)
    @inventory, @source, @restock_attributes = inventory, source, restock_attributes
  end

  def call
    restock_inventory
  end

  private

  attr_reader :inventory, :source, :restock_attributes

  def restock_inventory
    restock = source.restocks.build(**restock_attributes, inventory: inventory)

    if restock.save
      ServiceResponse.success(payload: {inventory:, restock:})
    else
      ServiceResponse.error(payload: {inventory:, restock:})
    end
  end
end
