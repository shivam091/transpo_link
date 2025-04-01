# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Stock < ApplicationRecord
  self.primary_key = :inventory_id

  attribute :quantity_in_hand, default: 0.0
  attribute :quantity_pending_to_buyer, default: 0.0

  validates :quantity_in_hand,
            presence: true,
            numericality: {greater_than_or_equal_to: 0.0},
            reduce: true
  validates :quantity_pending_to_buyer,
            presence: true,
            numericality: {greater_than_or_equal_to: 0.0},
            reduce: true

  belongs_to :inventory, inverse_of: :stock, touch: true
end
