# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::ReplenishService < ApplicationService
  def initialize(purchase_order)
    @purchase_order = purchase_order
  end

  def call
    replenish_inventory
  end

  private

  attr_reader :purchase_order

  def replenish_inventory
    purchase_order.purchase_order_items.each do |item|
      warehouse, product = purchase_order.warehouse, item.product
      inventory = warehouse.inventories.for_product(product)
      raise_missing_inventory_error!(warehouse, product) if inventory.nil?

      source_unit, target_unit = item.unit, inventory.unit
      quantity = UnitConversion.convert(source_unit, target_unit, item.quantity)

      Replenishments::UpdateService.(inventory, quantity, :increment)
    end
  end

  def raise_missing_inventory_error!(warehouse, product)
    raise PurchaseOrders::MissingInventoryError.new(warehouse, product)
  end
end
