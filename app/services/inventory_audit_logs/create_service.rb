# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module InventoryAuditLogs
  class CreateService < ApplicationService
    def initialize(inventory, inventory_movement)
      @inventory = inventory
      @inventory_movement = inventory_movement
    end

    def call
      audit_log_service_class.(inventory, inventory_movement)
    end

    private

    attr_reader :inventory, :inventory_movement

    def audit_log_service_class
      case inventory_movement.type.to_sym
      when :restock
        RestockService
      when :purchase
        PurchaseService
      else
        raise NotImplementedError, "Audit log service not implemented for #{inventory_movement.type}"
      end
    end
  end
end
