# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module InventoryAuditLogs
  class RestockService < BaseService
    protected

    def previous_quantity
      inventory.quantity_in_hand
    end

    def new_quantity
      inventory.quantity_in_hand + inventory_movement.quantity
    end
  end
end
