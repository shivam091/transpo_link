# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class InventoryBatch < ApplicationRecord
  include ActsAsMoney, NullifyIfBlank, Sanitizable, ScaleEnforcer

  LISTING_ATTRIBUTES = %i[batch_number expiration_date quantity cost_price].freeze

  nullify_if_blank :expiration_date

  sanitize_attributes :batch_number

  scale_attributes :quantity, :cost_price

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

  validate :validate_quantity_does_not_exceed_item_received_quantity

  validates_associated :restocks

  with_options inverse_of: :inventory_batch do |a|
    a.has_many :inventory_batch_audit_logs, dependent: :nullify
  end

  with_options inverse_of: :inventory_batches do |a|
    a.belongs_to :inventory, touch: true
    a.belongs_to :unit
  end

  belongs_to :source, polymorphic: true, optional: true

  has_one :product, through: :inventory
  has_one :warehouse, through: :inventory

  has_many :restocks, class_name: "Inventory::Restock", inverse_of: :inventory_batch, dependent: :destroy

  before_validation :auto_fill_cost_and_currency
  before_create :convert_to_inventory_unit
  after_save :record_audit_logs, :update_inventory_average_cost_price

  with_options prefix: true do |d|
    d.delegate :symbol, to: :unit
  end

  scope :by_batch_number_and_expiry, ->(batch_number, expiry) do
    where(
      arel_table[:batch_number].eq(batch_number)
        .and(arel_table[:expiration_date].eq(expiry))
    )
  end

  accepts_nested_attributes_for :restocks, allow_destroy: false

  def previous_quantity
    quantity_previously_was || 0.0
  end

  def quantity_change
    quantity - previous_quantity
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

  def manual_restock?
    source.nil?
  end

  def auto_fill_cost_and_currency
    return if manual_restock?

    if from_purchase_order_item?
      self.cost_price ||= source.unit_cost
      self.currency   ||= source.currency
    end
  end

  def from_purchase_order_item?
    source.is_a?(PurchaseOrderItem)
  end

  def update_inventory_average_cost_price
    Inventories::UpdateAverageCostPriceService.(inventory)
  end

  def convert_to_inventory_unit
    return if (target_unit = inventory.unit) == (source_unit = unit)

    self.quantity = UnitConversion.convert(source_unit, target_unit, quantity)
    self.unit = target_unit # Store in default unit
  end

  def record_audit_logs
    return unless saved_change_to_quantity?

    InventoryBatchAuditLogs::CreateService.(self)
  end

  def validate_quantity_does_not_exceed_item_received_quantity
    return unless from_purchase_order_item? && unit

    available_quantity = source.available_batch_quantity
    converted_batch_quantity = UnitConversion.convert(unit, source.unit, quantity.to_f)

    if converted_batch_quantity > available_quantity
      errors.add(:quantity, :exceeds_purchase_quantity, message: "exceeds the available quantity for this item")
    end
  end
end
