# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductPrice < ApplicationRecord
  include Sortable, ActsAsMoney

  LISTING_ATTRIBUTES = %i[warehouse_id min_quantity unit_price].freeze

  validates :min_quantity,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_price,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true

  with_options inverse_of: :product_prices do |a|
    a.belongs_to :product, touch: true
    a.belongs_to :warehouse, optional: true
  end

  delegate :name, to: :warehouse, prefix: true, allow_nil: true

  default_scope { order_created_desc }
end
