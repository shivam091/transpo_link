# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Product < ApplicationRecord
  include Toggleable, HasReferenceCode, Pageable, Sortable, ActsAsMoney,
          NullifyIfBlank, Sanitizable, Navigable

  LISTING_ATTRIBUTES = %i[
    reference_code name sku barcode cost_price product_category_id
  ].freeze

  attribute :min_stock_threshold, default: 0.0
  attribute :cost_price, default: 0.0

  nullify_if_blank :description, :barcode

  sanitize_attributes :name, :description, :sku, :barcode

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

  has_many :inventories, inverse_of: :product, dependent: :destroy
  has_many :product_prices, inverse_of: :product, dependent: :destroy
  has_many :feedbacks, as: :reviewable, inverse_of: :reviewable, dependent: :nullify
  has_many :purchase_order_items, inverse_of: :product, dependent: :restrict_with_exception

  belongs_to :product_category, counter_cache: true, inverse_of: :products
  belongs_to :unit, inverse_of: :products

  delegate :name, to: :product_category, prefix: true
  delegate :symbol, :category, to: :unit, prefix: true

  with_options allow_destroy: true do |n|
    n.accepts_nested_attributes_for :product_prices, reject_if: :reject_product_price?
  end

  class << self
    def select_options
      active.pluck(:name, :id)
    end
  end

  private

  def reject_product_price?(attributes)
    [
      attributes[:warehouse_id],
      attributes[:min_quantity],
      attributes[:unit_price],
      attributes[:currency]
    ].all?(&:blank?)
  end
end
