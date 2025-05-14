# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Replenishment < ApplicationRecord
  include ScaleEnforcer

  self.primary_key = :inventory_id

  scale_attributes :quantity_pending_from_supplier

  validates :quantity_pending_from_supplier,
            presence: true,
            numericality: {greater_than_or_equal_to: 0.0},
            reduce: true

  belongs_to :inventory, inverse_of: :replenishment, touch: true
end
