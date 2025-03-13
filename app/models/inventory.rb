# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventory < ApplicationRecord
  include HasReferenceCode

  attribute :stock_quantity, default: 0
  attribute :reserved_stock, default: 0
  attribute :cost_price, default: 0.0
  attribute :currency, default: Money.default_currency.iso_code

  has_many :inventory_movements, inverse_of: :inventory, dependent: :destroy
  has_many :inventory_audit_logs, inverse_of: :inventory, dependent: :destroy

  belongs_to :warehouse, inverse_of: :inventories
  belongs_to :product, inverse_of: :inventories, touch: true
end
