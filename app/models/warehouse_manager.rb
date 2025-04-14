# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehouseManager < ApplicationRecord
  with_options inverse_of: :warehouse_managers do |a|
    a.belongs_to :warehouse, touch: true
    a.belongs_to :manager, class_name: "User"
  end
end
