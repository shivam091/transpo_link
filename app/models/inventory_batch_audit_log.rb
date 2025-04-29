# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatchAuditLog < ApplicationRecord
  with_options inverse_of: :inventory_batch_audit_logs do |a|
    a.belongs_to :inventory_batch
    a.belongs_to :user
  end
end
