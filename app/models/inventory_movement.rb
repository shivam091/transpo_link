# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryMovement < ApplicationRecord
  enum :movement_type, {
    restock: "restock",
    purchase: "purchase",
    sale: "sale",
    return: "return",
    transfer_in: "transfer_in",
    transfer_out: "transfer_out",
    adjustment: "adjustment",
    reservation: "reservation"
  }

  has_many :inventory_audit_logs, inverse_of: :inventory_movement, dependent: :destroy

  belongs_to :inventory, inverse_of: :inventory_movements
  belongs_to :source, polymorphic: true, optional: true
end
