# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Stocks::UpdateService < ApplicationService
  def initialize(inventory, updates = {}, action)
    @inventory = inventory
    @updates = updates.transform_values(&:to_f)
    @action = action.to_sym
  end

  def call
    update_stock
  end

  private

  attr_reader :inventory, :updates, :action

  def update_stock
    adjust_stock!
  end

  def adjust_stock!
    stock = inventory.stock

    updates.each do |attribute, value|
      unless stock.respond_to?(attribute)
        raise ArgumentError, "Invalid attribute: #{attribute}"
      end

      case action
      when :increment
        stock.increment!(attribute, value)
      when :decrement
        stock.decrement!(attribute, value)
      else
        raise ArgumentError, "Invalid action"
      end
    end
  end
end
