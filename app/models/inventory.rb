# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory < ApplicationRecord
  include HasReferenceCode, Pageable, Sortable, ActsAsMoney, NullifyIfBlank,
          Sanitizable

  LISTING_ATTRIBUTES = %i[
    reference_code product_id warehouse_id batch_number stock_quantity
    reserved_stock cost_price
  ].freeze

  enum :tracking_method, {
    fifo: "fifo",
    lifo: "lifo",
    average_cost: "average_cost",
  }

  attribute :stock_quantity, default: 0.0
  attribute :reserved_stock, default: 0.0
  attribute :cost_price, default: 0.0
  attribute :tracking_method, :enum, default: tracking_methods[:average_cost]

  nullify_if_blank :batch_number, :expiration_date

  sanitize_attributes :batch_number

  validates :warehouse_id, presence: true, reduce: true
  validates :product_id,
            presence: true,
            uniqueness: {scope: :warehouse_id, message: :uniqueness},
            reduce: true
  validates :batch_number,
            length: {maximum: 55},
            allow_blank: true,
            reduce: true
  validates :cost_price,
            presence: true,
            numericality: {greater_than_or_equal_to: 0.0},
            reduce: true
  validates :expiration_date,
            comparison: {
              greater_than_or_equal_to: Date.current,
              message: :greater_than_or_equal_to
            },
            allow_nil: true,
            reduce: true
  validates :inventory_unit,
            presence: true,
            reduce: true
  validates :tracking_method,
            presence: true,
            inclusion: {in: tracking_methods.values},
            reduce: true

  validate :inventory_unit_is_in_valid_category

  has_many :inventory_movements, inverse_of: :inventory, dependent: :destroy
  has_many :inventory_audit_logs, inverse_of: :inventory, dependent: :destroy

  belongs_to :warehouse, inverse_of: :inventories
  belongs_to :product, inverse_of: :inventories, touch: true

  default_scope -> { order_created_desc }

  private

  def inventory_unit_is_in_valid_category
    return unless product.present? && inventory_unit.present?

    category = TranspoLink::MeasurementUnits.category_for_unit(product.capacity_unit)
    allowed_units = TranspoLink::MeasurementUnits.units_for(category).map(&:to_s)

    if allowed_units.blank? || !allowed_units.include?(inventory_unit)
      errors.add(:inventory_unit, :invalid)
    end
  end
end
