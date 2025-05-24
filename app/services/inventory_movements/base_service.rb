# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module InventoryMovements
  class BaseService < ApplicationService
    def initialize(inventory, source, inventory_movement_attributes)
      @inventory = inventory
      @source = source
      @inventory_movement_attributes = inventory_movement_attributes.dup.tap do |attrs|
        attrs[:inventory_id] = inventory.id
        attrs[:movement_type] = movement_type
      end
    end

    def call
      record_inventory_movement
    end

    private

    attr_reader :inventory, :source, :inventory_movement_attributes

    def record_inventory_movement
      inventory_movement = source.inventory_movements.build(inventory_movement_attributes)

      if inventory_movement.save
        ServiceResponse.success(payload: {inventory_movement:})
      else
        ServiceResponse.error(payload: {inventory_movement:})
      end
    end

    protected

    # Overridable hooks & methods
    def movement_type
      raise NotImplementedError, "Subclasses must implement `movement_type`"
    end
  end
end
