# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Inventories::ProductWarehouseUnitCategoryValidator < ActiveModel::Validator
  def validate(record)
    return unless (warehouse = record.warehouse) && (product = record.product)

    allowed_units = Unit.for_category(warehouse.unit_category).symbols

    if allowed_units.blank? || allowed_units.exclude?(product.unit_symbol)
      record.errors.add(:product_id, :incompatible_unit_category)
    end
  end
end
