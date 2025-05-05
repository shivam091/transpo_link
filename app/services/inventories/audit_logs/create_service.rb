# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module Inventories
  module AuditLogs
    class CreateService < ApplicationService
      def initialize(inventory, movement)
        @inventory = inventory
        @movement = movement
      end

      def call
        audit_log_service_class.(inventory, movement)
      end

      private

      attr_reader :inventory, :movement

      def audit_log_service_class
        case movement.type.to_sym
        when :restock
          RestockService
        when :purchase
          PurchaseService
        else
          raise NotImplementedError, "Audit log service not implemented for #{movement.type}"
        end
      end
    end
  end
end
