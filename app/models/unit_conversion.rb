# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UnitConversion < ApplicationRecord
  include Sortable

  LISTING_ATTRIBUTES = %i[from_unit to_unit conversion_rate].freeze

  validates :from_unit,
            presence: true,
            inclusion: {in: TranspoLink::MeasurementUnits.all_units.map(&:to_s)},
            uniqueness: {
              scope: [:product_id, :to_unit],
              message: :uniqueness,
              case_sensitive: false
            },
            reduce: true
  validates :to_unit,
            presence: true,
            inclusion: {in: TranspoLink::MeasurementUnits.all_units.map(&:to_s)},
            reduce: true
  validates :conversion_rate,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true

  belongs_to :product, inverse_of: :unit_conversions, touch: true

  default_scope { order_created_desc }
end
