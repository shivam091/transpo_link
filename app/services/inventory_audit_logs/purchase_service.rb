# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module InventoryAuditLogs
  class PurchaseService < BaseService
    protected

    def previous_quantity
      inventory.inventory_movements.purchase.sum(&:quantity) - inventory_movement.quantity
    end

    def new_quantity
      inventory.inventory_movements.purchase.sum(&:quantity)
    end
  end
end
