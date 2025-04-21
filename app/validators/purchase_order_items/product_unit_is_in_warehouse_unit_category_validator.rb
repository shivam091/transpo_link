# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrderItems::ProductUnitIsInWarehouseUnitCategoryValidator < ActiveModel::Validator
  def validate(record)
    return unless (warehouse = record.purchase_order&.warehouse) && (product = record.product)

    allowed_symbols = Unit.for_category(warehouse.unit_category).symbols

    if allowed_symbols.exclude?(product.unit_symbol)
      record.errors.add(:product_id, :unit_category_mismatch)
    end
  end
end
