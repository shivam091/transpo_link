# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryAuditLog < ApplicationRecord
  with_options inverse_of: :inventory_audit_logs do |a|
    a.belongs_to :inventory
    a.belongs_to :inventory_movement, optional: true
    a.belongs_to :user
  end
end
