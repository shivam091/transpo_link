# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryAuditLog < ApplicationRecord
  belongs_to :inventory, inverse_of: :inventory_audit_logs
  belongs_to :inventory_movement, inverse_of: :inventory_audit_logs, optional: true
  belongs_to :user, inverse_of: :inventory_audit_logs
end
