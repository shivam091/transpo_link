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

  with_options inverse_of: :inventory_batch do |a|
    a.has_many :inventory_batch_audit_logs, dependent: :nullify
    a.has_many :inventory_batch_processing_logs, dependent: :nullify
  end

  with_options inverse_of: :inventory_batches do |a|
    a.belongs_to :inventory, touch: true
    a.belongs_to :unit
  end

  after_save :update_inventory_average_cost_price

  private

  def update_inventory_average_cost_price
    Inventories::UpdateAverageCostPriceService.(inventory)
  end
end
