# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryAuditLogs::CreateService < ApplicationService
  def initialize(inventory, inventory_movement)
    @inventory, @inventory_movement = inventory, inventory_movement
  end

  def call
    create_inventory_audit_log
  end

  private

  attr_reader :inventory, :inventory_movement

  def create_inventory_audit_log
    audit_log_attributes = {
      inventory: inventory,
      movement_type: inventory_movement.movement_type,
      previous_quantity: inventory.quantity_in_hand,
      new_quantity: (inventory.quantity_in_hand + inventory_movement.quantity),
      metadata: {source: inventory_movement.source_type, source_id: inventory_movement.source_id}
    }

    inventory_audit_log = inventory_movement.inventory_audit_logs.build(audit_log_attributes)

    if inventory_audit_log.save
      ServiceResponse.success(payload: {inventory_audit_log:})
    else
      ServiceResponse.error(payload: {inventory_audit_log:})
    end
  end
end
