# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module Inventories
  module Movements
    class BaseService < ApplicationService
      def initialize(inventory, source, movement_attributes)
        @inventory = inventory
        @source = source
        @movement_attributes = movement_attributes.dup.tap do |attrs|
          attrs[:inventory_id] = inventory.id
        end
      end

      def call
        record_movement
      end

      private

      attr_reader :inventory, :source, :movement_attributes

      def record_movement
        movement = source.send(type.to_s.pluralize).build(movement_attributes)

        if movement.save
          ServiceResponse.success(payload: {movement:})
        else
          ServiceResponse.error(payload: {movement:})
        end
      end

      protected

      # Overridable hooks & methods
      def type
        raise NotImplementedError, "Subclasses must implement `type`"
      end
    end
  end
end
