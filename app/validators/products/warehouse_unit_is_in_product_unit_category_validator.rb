# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Products::WarehouseUnitIsInProductUnitCategoryValidator < ActiveModel::Validator
  def validate(record)
    return unless (warehouse = record.warehouse) && (product = record.product)

    allowed_units = Unit.for_category(product.unit_category).symbols

    if allowed_units.blank? || allowed_units.exclude?(warehouse.unit_symbol)
      record.errors.add(:warehouse_id, :unit_category_mismatch)
    end
  end
end
