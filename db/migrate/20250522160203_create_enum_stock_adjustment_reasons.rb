# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumStockAdjustmentReasons < ActiveRecord::Migration[8.0]
  def change
    create_enum :stock_adjustment_reasons, %i[
      stock_count_discrepancy
      damaged_goods
      expired_stock
      theft_or_loss
      sample_issued
      administrative_correction
      misplaced_then_found
      overstock_correction
      shrinkage
      pallet_breakage
      found_during_audit
      cycle_count_adjustment
      donated
      disposal
      used_internally
    ]
  end
end
