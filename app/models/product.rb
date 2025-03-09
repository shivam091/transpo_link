# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Product < ApplicationRecord
  include Toggleable, HasReferenceCode, Pageable, Sortable

  attribute :min_stock_threshold, default: 0
  attribute :cost_price, default: 0.0
  attribute :currency, default: Money.default_currency.iso_code
  attribute :is_active, default: false

  has_many :inventories, inverse_of: :product, dependent: :destroy
  has_many :product_prices, inverse_of: :product, dependent: :destroy

  belongs_to :product_category, counter_cache: true, inverse_of: :products

  delegate :name, to: :product_category, prefix: true

  default_scope -> { order_created_desc }
end
