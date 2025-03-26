# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Warehouse < ApplicationRecord
  include Toggleable, HasReferenceCode, Pageable, Sortable, Sanitizable,
          NullifyIfBlank

  LISTING_ATTRIBUTES = %i[
    reference_code name email_address contact_number capacity latitude longitude
  ].freeze

  nullify_if_blank :email_address, :contact_number, :description, :latitude, :longitude

  sanitize_attributes :name, :email_address, :contact_number, :description

  validates :name,
            presence: true,
            length: {in: 2..255},
            reduce: true
  validates :email_address,
            length: {in: 2..55},
            email: true,
            uniqueness: {case_sensitive: true},
            allow_blank: true,
            reduce: true
  validates :contact_number,
            length: {in: 2..55},
            allow_blank: true,
            reduce: true
  validates :description,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true
  validates :total_capacity,
            presence: true,
            numericality: {greater_than: 0, less_than: 10**10},
            reduce: true
  validates :capacity_unit,
            presence: true,
            inclusion: {in: TranspoLink::MeasurementUnits.all_units.map(&:to_s)},
            reduce: true
  validates :latitude,
            numericality: {
              greater_than_or_equal_to: -90,
              less_than_or_equal_to: 90
            },
            allow_nil: true,
            reduce: true
  validates :longitude,
            numericality: {
              greater_than_or_equal_to: -180,
              less_than_or_equal_to: 180
            },
            allow_nil: true,
            reduce: true
  validates :manager_ids, presence: true, reduce: true
  validates :supplier_ids, presence: true, reduce: true

  has_one :address, as: :addressable, inverse_of: :addressable, dependent: :destroy

  has_many :warehouse_managers, inverse_of: :warehouse, dependent: :destroy
  has_many :managers, through: :warehouse_managers, inverse_of: :managed_warehouses, source: :manager

  has_many :warehouse_suppliers, inverse_of: :warehouse, dependent: :destroy
  has_many :suppliers, through: :warehouse_suppliers, inverse_of: :supplied_warehouses, source: :supplier

  has_many :product_prices, inverse_of: :warehouse, dependent: :restrict_with_exception
  has_many :inventories, inverse_of: :warehouse, dependent: :restrict_with_exception

  default_scope -> { order_created_desc }

  accepts_nested_attributes_for :address, update_only: true

  class << self
    def select_options
      active.pluck(:name, :id)
    end
  end

  def address
    super.presence || build_address
  end
end
