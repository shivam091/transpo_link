# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PurchaseOrders
  class MissingInventoryError < PurchaseOrderError
    def initialize(product)
      super(:missing_inventory, context: {product_name: product.name})
    end
  end
end
