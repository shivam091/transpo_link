# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::DeliveryWorkflowService < ApplicationService
  def initialize(purchase_order_item, inventory_batch_attributes)
    @purchase_order_item = purchase_order_item
    @inventory_batch_attributes = inventory_batch_attributes
    @purchase_order = purchase_order_item.purchase_order
    @inventory = @purchase_order.warehouse.inventories.for_product(@purchase_order_item.product)
  end

  def call
    process_delivery_workflow
  end

  private

  attr_reader :purchase_order_item, :inventory_batch_attributes,
              :purchase_order, :inventory, :inventory_batch

  def process_delivery_workflow
    service_response = nil

    ActiveRecord::Base.transaction do
      service_response = create_or_merge_inventory_batch

      @inventory_batch = service_response.payload[:inventory_batch]

      raise ActiveRecord::Rollback unless service_response.success?

      restock = create_inventory_movement.payload[:restock]

      update_replenishment(restock.quantity)
      update_stock(restock.quantity)
      deliver_purchase_order_item(restock.quantity)
    rescue => exception
      debugger
      service_response = ServiceResponse.error(payload: {inventory_batch:})

      raise ActiveRecord::Rollback
    end

    service_response
  end

  def create_or_merge_inventory_batch
    InventoryBatches::UpsertService.(inventory, inventory_batch_attributes)
  end

  def create_inventory_movement
    restock_attributes = {
      quantity: inventory_batch.quantity_change,
      unit_id: inventory_batch.unit_id,
      unit_cost: purchase_order_item.unit_cost,
      total_cost: purchase_order_item.total_cost,
      currency: inventory_batch.currency
    }

    Inventories::RestockService.(inventory, purchase_order_item, restock_attributes)
  end

  def update_replenishment(received_quantity)
    Replenishments::UpdateService.(inventory, received_quantity, :decrement)
  end

  def update_stock(received_quantity)
    Stocks::UpdateService.(inventory, {quantity_in_hand: received_quantity}, :increment)
  end

  def deliver_purchase_order_item(received_quantity)
    unless (source_unit = inventory.unit) == (target_unit = purchase_order_item.unit)
      received_quantity = UnitConversion.convert(source_unit, target_unit, received_quantity)
    end

    PurchaseOrderItems::ProcessDeliveryService.(purchase_order_item, received_quantity)
  end
end
