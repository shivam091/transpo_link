# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory < ApplicationRecord
  attribute :stock_quantity, default: 0
  attribute :reserved_stock, default: 0
  attribute :cost_price, default: 0.0
  attribute :currency, default: Money.default_currency.iso_code

  belongs_to :warehouse, inverse_of: :inventories
  belongs_to :product, inverse_of: :inventories
end
