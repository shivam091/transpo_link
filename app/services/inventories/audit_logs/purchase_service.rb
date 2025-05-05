# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module Inventories
  module AuditLogs
    class PurchaseService < BaseService
      protected

      def previous_quantity
        inventory.movements.purchase.sum(&:quantity) - movement.quantity
      end

      def new_quantity
        inventory.movements.purchase.sum(&:quantity)
      end
    end
  end
end
