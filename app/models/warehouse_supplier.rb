# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehouseSupplier < ApplicationRecord
  belongs_to :warehouse, inverse_of: :warehouse_suppliers, touch: true
  belongs_to :supplier, inverse_of: :warehouse_suppliers, class_name: "User"
end
