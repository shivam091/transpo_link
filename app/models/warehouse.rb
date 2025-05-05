# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Warehouse < ApplicationRecord
  include Toggleable, HasReferenceCode, Pageable, Sortable, Sanitizable,
          NullifyIfBlank, Navigable, ScaleEnforcer

  LISTING_ATTRIBUTES = %i[
    reference_code name email_address contact_number capacity latitude longitude
  ].freeze

  nullify_if_blank :email_address, :contact_number, :description, :latitude, :longitude

  sanitize_attributes :name, :email_address, :contact_number, :description

  scale_attributes :total_capacity, :latitude, :longitude

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
            numericality: {greater_than: 0.0, less_than: 100_000_000_000.0},
            reduce: true
  validates :unit_id, presence: true, reduce: true
  validates :latitude,
            numericality: {
              greater_than_or_equal_to: -90.0,
              less_than_or_equal_to: 90.0
            },
            allow_nil: true,
            reduce: true
  validates :longitude,
            numericality: {
              greater_than_or_equal_to: -180.0,
              less_than_or_equal_to: 180.0
            },
            allow_nil: true,
            reduce: true

  has_one :address, as: :addressable, inverse_of: :addressable, dependent: :destroy

  with_options inverse_of: :warehouse, dependent: :restrict_with_exception do |a|
    a.has_many :product_prices
    a.has_many :inventories
    a.has_many :purchase_orders
    a.has_many :purchase_order_items, class_name: "PurchaseOrder::Item", through: :purchase_orders, source: :items
  end

  has_many :warehouse_managers, class_name: "Warehouse::Manager", inverse_of: :warehouse, dependent: :destroy
  has_many :managers, through: :warehouse_managers, inverse_of: :managed_warehouses, source: :manager

  has_many :warehouse_suppliers, class_name: "Warehouse::Supplier", inverse_of: :warehouse, dependent: :destroy
  has_many :suppliers, through: :warehouse_suppliers, inverse_of: :supplied_warehouses, source: :supplier

  has_many :products, through: :inventories, inverse_of: :warehouses

  belongs_to :unit, inverse_of: :warehouses

  delegate :symbol, :category, to: :unit, prefix: true

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
