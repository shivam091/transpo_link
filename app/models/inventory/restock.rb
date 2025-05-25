# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory::Restock < ApplicationRecord
  include ScaleEnforcer, NullifyIfBlank, Sanitizable

  scale_attributes :quantity

  nullify_if_blank :note

  sanitize_attributes :comment, :note

  validates :quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_id,
            presence: true,
            reduce: true
  validates :comment,
            presence: true,
            length: {maximum: 1000},
            reduce: true
  validates :note,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true

  validate :quantity_cannot_exceed_stock_restockable_quantity

  has_many :inventory_movements, as: :source, dependent: :destroy

  belongs_to :inventory_batch, inverse_of: :restocks
  belongs_to :unit, inverse_of: :restocks

  after_create :restock_inventory

  private

  def restock_inventory
    InventoryBatches::RestockService.(inventory_batch, self)
  end

  def quantity_cannot_exceed_stock_restockable_quantity
    return unless inventory_batch && quantity && unit

    converted_quantity = UnitConversion.convert!(unit, inventory_batch.unit, quantity)

    if converted_quantity > inventory_batch.restockable_quantity
      errors.add(:quantity, :exceeds_available_batch_quantity)
    end
  end
end
