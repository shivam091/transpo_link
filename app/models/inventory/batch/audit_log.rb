# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory::Batch::AuditLog < ApplicationRecord
  belongs_to :batch, class_name: "Inventory::Batch", inverse_of: :audit_logs
  belongs_to :user, inverse_of: :inventory_batch_audit_logs
end
