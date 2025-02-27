# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class WarehouseManager < ApplicationRecord
  validates :warehouse_id, :manager_id, presence: true, reduce: true
  belongs_to :warehouse, inverse_of: :warehouse_managers, touch: true
  belongs_to :manager, inverse_of: :warehouse_managers, class_name: "User"
end
