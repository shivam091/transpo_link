# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PurchaseOrders
  class UnitConversionError < PurchaseOrderError
    def initialize(source_unit, target_unit)
      source_unit = I18n.t(source_unit.symbol, scope: "measurement_units.sub_categories")
      target_unit = I18n.t(target_unit.symbol, scope: "measurement_units.sub_categories")

      super(:unit_conversion_failed, context: {source_unit:, target_unit:})
    end
  end
end
