# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module Inventories
  module AuditLogs
    class BaseService < ApplicationService
      def initialize(inventory, movement)
        @inventory = inventory
        @movement = movement
      end

      def call
        create_audit_log
      end

      private

      attr_reader :inventory, :movement

      def create_audit_log
        audit_log = movement.audit_logs.build(
          inventory: inventory,
          type: movement.type,
          previous_quantity: previous_quantity,
          new_quantity: new_quantity,
          metadata: {source_type: movement.source_type, source_id: movement.source_id}
        )

        if audit_log.save
          ServiceResponse.success(payload: {audit_log:})
        else
          ServiceResponse.error(payload: {audit_log:})
        end
      end

      protected

      def previous_quantity
        raise NotImplementedError, "Subclasses must implement `previous_quantity`"
      end

      def new_quantity
        raise NotImplementedError, "Subclasses must implement `new_quantity`"
      end
    end
  end
end
