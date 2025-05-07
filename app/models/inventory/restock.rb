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

  belongs_to :inventory_batch, inverse_of: :restocks
  belongs_to :unit, inverse_of: :restocks
end
