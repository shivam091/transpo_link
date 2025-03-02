# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRate < ApplicationRecord
  include Pageable, Taxable, Sortable

  enum :business_category, {
    b2b: "b2b",
    b2c: "b2c"
  }

  attribute :business_category, :enum, default: business_categories[:b2b]

  default_scope -> { order_created_desc }
end
