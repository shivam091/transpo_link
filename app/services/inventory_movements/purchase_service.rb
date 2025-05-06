# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module InventoryMovements
  class PurchaseService < BaseService
    protected

    def movement_type
      InventoryMovement.movement_types[:purchase]
    end
  end
end
