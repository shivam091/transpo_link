# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Replenishments::UpdateService < ApplicationService
  def initialize(inventory, quantity, action)
    @inventory, @quantity, @action = inventory, quantity, action.to_sym
  end

  def call
    update_replenishment
  end

  private

  attr_reader :inventory, :quantity, :action

  def update_replenishment
    adjust_pending_quantity!
  end

  def adjust_pending_quantity!
    replenishment = inventory.replenishment

    case action.to_sym
    when :increment
      replenishment.increment!(:quantity_pending_from_supplier, quantity)
    when :decrement
      replenishment.decrement!(:quantity_pending_from_supplier, quantity)
    else
      raise ArgumentError, "Invalid action"
    end
  end
end
