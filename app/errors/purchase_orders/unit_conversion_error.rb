# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PurchaseOrders
  class UnitConversionError < PurchaseOrderError
    def initialize(product)
      super(:unit_conversion_failed, context: {product_name: product.name})
    end
  end
end
