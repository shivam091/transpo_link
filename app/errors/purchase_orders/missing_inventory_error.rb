# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PurchaseOrders
  class MissingInventoryError < PurchaseOrderError
    def initialize(warehouse, product)
      super(:missing_inventory, context: {warehouse_name: warehouse.name, product_name: product.name})
    end
  end
end
