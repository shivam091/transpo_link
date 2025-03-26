# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::UpdateService < ApplicationService
  def initialize(inventory, inventory_attributes)
    @inventory, @inventory_attributes = inventory, inventory_attributes
  end

  def call
    update_inventory
  end

  private

  attr_reader :inventory, :inventory_attributes

  def update_inventory
    if inventory.update(inventory_attributes)
      ServiceResponse.success(payload: {inventory:})
    else
      ServiceResponse.error(payload: {inventory:})
    end
  end
end
