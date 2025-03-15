# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Product < ApplicationRecord
  include Toggleable, HasReferenceCode, Pageable, Sortable, ActsAsMoney

  LISTING_ATTRIBUTES = %i[
    reference_code name sku barcode cost_price product_category_id
  ].freeze

  attribute :min_stock_threshold, default: 0
  attribute :cost_price, default: 0.0
  attribute :currency, default: Money.default_currency.iso_code
  attribute :is_active, default: false

  has_many :inventories, inverse_of: :product, dependent: :destroy
  has_many :product_prices, inverse_of: :product, dependent: :destroy
  has_many :unit_conversions, inverse_of: :product, dependent: :destroy
  has_many :feedbacks, as: :reviewable, inverse_of: :reviewable, dependent: :nullify

  belongs_to :product_category, counter_cache: true, inverse_of: :products

  delegate :name, to: :product_category, prefix: true

  default_scope -> { order_created_desc }

  with_options allow_destroy: true do |n|
    n.accepts_nested_attributes_for :unit_conversions, reject_if: :reject_unit_conversion?
    n.accepts_nested_attributes_for :product_prices, reject_if: :reject_product_price?
  end

  private

  def reject_unit_conversion?(attributes)
    [
      attributes[:from_unit],
      attributes[:to_unit],
      attributes[:conversion_rate]
    ].all?(&:blank?)
  end

  def reject_product_price?(attribute)
    [
      attributes[:warehouse_id],
      attributes[:min_quantity],
      attributes[:unit_price],
      attribute[:currency]
    ].all?(&:blank?)
  end
end
