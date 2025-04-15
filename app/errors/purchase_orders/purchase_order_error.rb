# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PurchaseOrders
  class PurchaseOrderError < ApplicationError
    def default_scope
      "errors.purchase_orders"
    end
  end
end
