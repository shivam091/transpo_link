# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Warehouse::Supplier < ApplicationRecord
  with_options inverse_of: :warehouse_suppliers do |a|
    a.belongs_to :warehouse, touch: true
    a.belongs_to :supplier, class_name: "User"
  end
end
