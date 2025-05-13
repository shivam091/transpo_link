# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module InventoryMovements
  class RestockService < BaseService
    protected

    def movement_type
      InventoryMovement.movement_types[:restock]
    end
  end
end
