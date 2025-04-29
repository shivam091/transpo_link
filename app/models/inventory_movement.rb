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

  validates :quantity,
            presence: true,
            numericality: {other_than: 0.0},
            reduce: true
  validates :unit_cost,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :total_cost,
            presence: true,
            numericality: {greater_than_or_equal_to: :unit_cost},
            if: -> { unit_cost.present? },
            reduce: true
  validates :movement_type,
            presence: true,
            inclusion: {in: movement_types.keys},
            reduce: true

  has_many :inventory_audit_logs, inverse_of: :inventory_movement, dependent: :destroy

  with_options inverse_of: :inventory_movements do |a|
    a.belongs_to :inventory
    a.belongs_to :unit
  end

  belongs_to :source, polymorphic: true, optional: true

  before_save :set_default_attributes
  after_create :create_inventory_audit_log

  private

  def set_default_attributes
    self.movement_date = Time.now.utc
    self.metadata = {action: movement_type}
  end

  def create_inventory_audit_log
    InventoryAuditLogs::CreateService.(inventory, self)
  end
end
