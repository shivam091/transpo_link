# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Warehouse < ApplicationRecord
  include Toggleable, HasReferenceCode

  has_one :address, as: :addressable, inverse_of: :addressable, dependent: :destroy

  has_many :warehouse_managers, inverse_of: :warehouse, dependent: :destroy
  has_many :managers, through: :warehouse_managers, inverse_of: :managed_warehouses, source: :manager

  has_many :warehouse_suppliers, inverse_of: :warehouse, dependent: :destroy
  has_many :suppliers, through: :warehouse_suppliers, inverse_of: :supplied_warehouses, source: :supplier
end
