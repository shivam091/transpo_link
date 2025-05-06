# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UnitIsInProductUnitCategoryValidator < ActiveModel::Validator
  def validate(record)
    return unless (product = record.product) && (unit = record.unit)

    allowed_units = Unit.for_category(product.unit_category).symbols

    if allowed_units.blank? || allowed_units.exclude?(unit.symbol)
      record.errors.add(:unit_id, :incompatible_unit_category)
    end
  end
end
