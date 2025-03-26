# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::CreateService < ApplicationService
  def initialize(inventory_attributes)
    @inventory_attributes = inventory_attributes
  end

  def call
    create_inventory
  end

  private

  attr_reader :inventory_attributes

  def create_inventory
    inventory = Inventory.new(inventory_attributes)

    if inventory.save
      ServiceResponse.success(payload: {inventory:})
    else
      ServiceResponse.error(payload: {inventory:})
    end
  end
end
