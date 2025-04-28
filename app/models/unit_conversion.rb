# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UnitConversion < ApplicationRecord
  include Pageable, ScaleEnforcer

  LISTING_ATTRIBUTES = %i[source_unit_id target_unit_id multiplier].freeze

  scale_attributes :multiplier

  validates :source_unit_id,
            presence: true,
            uniqueness: {scope: :target_unit_id, message: :uniqueness},
            reduce: true
  validates :target_unit_id, presence: true, reduce: true
  validates :multiplier,
            presence: true,
            numericality: {greater_than: 0.0},
            reduce: true

  validate :units_must_be_different
  validate :units_must_have_same_category

  with_options class_name: "Unit" do |a|
    a.belongs_to :source_unit, foreign_key: :source_unit_id, inverse_of: :source_conversions
    a.belongs_to :target_unit, foreign_key: :target_unit_id, inverse_of: :target_conversions
  end

  default_scope do
    unit_arel = Unit.arel_table
    join = arel_table.join(unit_arel)
      .on(arel_table[:source_unit_id].eq(unit_arel[:id]))
      .join_sources
    joins(join).order(unit_arel[:symbol].asc)
  end

  delegate :symbol, :category, to: :source_unit, prefix: true
  delegate :symbol, :category, to: :target_unit, prefix: true

  class << self
    def convert(source_unit, target_unit, quantity)
      return quantity if source_unit == target_unit

      unit_conversion = find_by(
        arel_table[:source_unit_id].eq(source_unit.id)
          .and(arel_table[:target_unit_id].eq(target_unit.id))
      )

      # raise error if no conversion exists
      raise UnitConversionError.new(source_unit, target_unit) unless unit_conversion

      quantity * unit_conversion.multiplier
    end
  end

  private

  def units_must_be_different
    return if source_unit_id.blank? || target_unit_id.blank?

    if source_unit_id == target_unit_id
      errors.add(:target_unit_id, :same_as_source_unit, message: "must be different from source unit")
    end
  end

  def units_must_have_same_category
    return unless source_unit && target_unit

    if source_unit_category != target_unit_category
      errors.add(:target_unit_id, :category_mismatch, message: "must belong to the same category as source unit")
    end
  end
end
