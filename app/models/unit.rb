# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Unit < ApplicationRecord
  include Pageable, Sanitizable

  LISTING_ATTRIBUTES = %i[symbol category].freeze

  enum :category, {
    count: "count",
    length: "length",
    weight: "weight",
    area: "area",
    volume: "volume"
  }, prefix: true

  sanitize_attributes :symbol

  validates :category,
            presence: true,
            inclusion: {in: categories.values},
            reduce: true
  validates :symbol,
            presence: true,
            uniqueness: {scope: :category, message: :uniqueness},
            reduce: true

  with_options class_name: "UnitConversion", dependent: :restrict_with_exception do |a|
    a.has_many :source_conversions, foreign_key: :source_unit_id, inverse_of: :source_unit
    a.has_many :target_conversions, foreign_key: :target_unit_id, inverse_of: :target_unit
  end

  with_options inverse_of: :unit, dependent: :restrict_with_exception do |a|
    a.has_many :warehouses
    a.has_many :products
    a.has_many :inventories
    a.has_many :inventory_batches
    a.has_many :inventory_movements
    a.has_many :purchase_order_items
    a.has_many :delivered_po_items, class_name: "PurchaseOrderItem::Delivery"
    a.has_many :restocks, class_name: "Inventory::Restock"
  end

  scope :for_category, ->(category) { where(arel_table[:category].eq(category)) }

  class << self
    def select_options(category = nil)
      target_units = category ? for_category(category) : all

      target_units.group_by(&:category)
    end

    def symbols
      all.map(&:symbol)
    end
  end
end
