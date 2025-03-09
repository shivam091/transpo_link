# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductPrice < ApplicationRecord
  attribute :min_quantity, default: 1
  attribute :unit_price, default: 0.0
  attribute :currency, default: Money.default_currency.iso_code

  belongs_to :product
  belongs_to :warehouse, optional: true
end
