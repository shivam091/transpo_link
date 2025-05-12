# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatchAuditLogs::CreateService < ApplicationService
  def initialize(inventory_batch)
    @inventory_batch = inventory_batch
  end

  def call
    create_audit_log
  end

  private

  attr_reader :inventory_batch

  def create_audit_log
    audit_log_attributes = {
      previous_quantity: inventory_batch.previous_quantity,
      new_quantity: inventory_batch.quantity,
      metadata: {}
    }

    inventory_batch.inventory_batch_audit_logs.create!(audit_log_attributes)
  end
end
