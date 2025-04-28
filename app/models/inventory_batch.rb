# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatch < ApplicationRecord
  include ActsAsMoney, NullifyIfBlank, Sanitizable

  nullify_if_blank :expiration_date

  sanitize_attributes :batch_number

  validates :batch_number,
            presence: true,
            length: {maximum: 55},
            uniqueness: {scope: :inventory_id, message: :uniqueness},
            reduce: true
  validates :expiration_date,
            comparison: {
              greater_than_or_equal_to: Date.current,
              message: :greater_than_or_equal_to
            },
            allow_nil: true,
            reduce: true
  validates :quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :cost_price,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_id, presence: true, reduce: true

  with_options inverse_of: :inventory_batches do |a|
    a.belongs_to :inventory, touch: true
    a.belongs_to :unit
  end

  before_create :convert_to_inventory_unit
  after_save :update_inventory_average_cost_price

  scope :by_batch_number_and_expiry, ->(batch_number, expiry) do
    where(
      arel_table[:batch_number].eq(batch_number)
        .and(arel_table[:expiration_date].eq(expiry))
    )
  end

  def quantity_change
    quantity - (quantity_previously_was || 0)
  end

  def merge_with!(attributes)
    quantity = attributes.fetch(:quantity) { raise ArgumentError, "Quantity must be present" }

    # Considered batch's unit as target unit because inventory unit is set
    # to batch at the time of creation via #convert_to_inventory_unit.
    source_unit, target_unit = attributes[:source_unit], unit

    quantity_to_add = if source_unit && source_unit != target_unit
      UnitConversion.convert(source_unit, target_unit, quantity)
    else
      quantity
    end

    self.quantity += quantity_to_add

    save!
  end

  private

  def update_inventory_average_cost_price
    Inventories::UpdateAverageCostPriceService.(inventory)
  end

  def convert_to_inventory_unit
    return if (target_unit = inventory.unit) == (source_unit = unit)

    self.quantity = UnitConversion.convert(source_unit, target_unit, quantity)
    self.unit = target_unit # Store in default unit
  end
end
