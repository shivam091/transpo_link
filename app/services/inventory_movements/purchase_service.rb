# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module InventoryMovements
  class PurchaseService < BaseService
    protected

    def type
      Inventory::Movement.types[:purchase]
    end
  end
end
