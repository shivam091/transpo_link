# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory::Restock < ApplicationRecord
  validates :comment,
            presence: true,
            length: {maximum: 1000},
            reduce: true
  validates :note,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true

  belongs_to :inventory_batch, inverse_of: :restocks
end
