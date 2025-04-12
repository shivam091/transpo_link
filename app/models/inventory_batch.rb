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

  belongs_to :inventory, inverse_of: :inventory_batches, touch: true
  belongs_to :unit, inverse_of: :inventory_batches
end
