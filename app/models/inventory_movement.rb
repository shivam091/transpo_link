# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryMovement < ApplicationRecord
  include ScaleEnforcer, Sortable

  LISTING_ATTRIBUTES = %i[movement_date movement_type quantity unit_cost total_cost].freeze

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

  scale_attributes :quantity, :unit_cost, :total_cost

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
  before_create :convert_to_inventory_unit
  after_create :create_inventory_audit_log

  with_options prefix: true do |d|
    d.delegate :symbol, to: :unit
  end

  default_scope { order_created_desc }

  private

  def set_default_attributes
    self.movement_date = Time.now.utc
    self.metadata = {action: movement_type}
  end

  def create_inventory_audit_log
    InventoryAuditLogs::CreateService.(inventory, self)
  end

  def convert_to_inventory_unit
    return if (target_unit = inventory.unit) == (source_unit = unit)

    self.quantity = UnitConversion.convert(source_unit, target_unit, quantity)
    self.unit = target_unit # Store in default unit
  end
end
