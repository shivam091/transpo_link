# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRate < ApplicationRecord
  include Pageable, Taxable, Sortable

  default_scope -> { order_created_desc }
end
