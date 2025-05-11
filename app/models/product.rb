# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Product < ApplicationRecord
  include Toggleable, HasReferenceCode, Pageable, Sortable, ActsAsMoney,
          NullifyIfBlank, Sanitizable, Navigable, ScaleEnforcer

  LISTING_ATTRIBUTES = %i[
    reference_code name sku barcode cost_price product_category_id
  ].freeze

  attribute :min_stock_threshold, default: 10.0

  nullify_if_blank :description, :barcode

  sanitize_attributes :name, :description, :sku, :barcode

  scale_attributes :min_stock_threshold, :cost_price

  validates :name,
            presence: true,
            length: {in: 2..255},
            reduce: true
  validates :description,
            length: {maximum: 2000},
            allow_blank: true,
            reduce: true
  validates :sku,
            presence: true,
            length: {maximum: 50},
            uniqueness: true,
            reduce: true
  validates :barcode,
            length: {maximum: 50},
            uniqueness: true,
            allow_blank: true,
            reduce: true
  validates :min_stock_threshold,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :unit_id, presence: true, reduce: true
  validates :cost_price,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true
  validates :product_category_id,
            presence: true,
            reduce: true

  validates_associated :product_prices

  with_options inverse_of: :product do |a|
    a.has_many :inventories, dependent: :destroy
    a.has_many :product_prices, dependent: :destroy
    a.has_many :purchase_order_items, dependent: :restrict_with_exception
  end

  with_options inverse_of: :products do |a|
    a.belongs_to :product_category, counter_cache: true
    a.belongs_to :unit
  end

  has_many :feedbacks, as: :reviewable, inverse_of: :reviewable, dependent: :nullify
  has_many :warehouses, through: :inventories, inverse_of: :products

  delegate :name, to: :product_category, prefix: true
  delegate :symbol, :category, to: :unit, prefix: true

  accepts_nested_attributes_for :product_prices, reject_if: :reject_product_price?, allow_destroy: true

  class << self
    def select_options
      active.pluck(:name, :id)
    end
  end

  def price_for(quantity, warehouse, date: Date.current)
    @price_for ||= {}
    @price_for[[quantity, warehouse&.id, date]] ||= begin
      product_prices.best_price_for(warehouse:, quantity:, date:)&.unit_price || cost_price
    end
  end

  private

  def reject_product_price?(attributes)
    [
      attributes[:warehouse_id],
      attributes[:min_quantity],
      attributes[:unit_id],
      attributes[:unit_price],
      attributes[:effective_from],
      attributes[:effective_until]
    ].all?(&:blank?)
  end
end
