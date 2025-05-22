# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumStockAdjustmentTypes < ActiveRecord::Migration[8.0]
  def change
    create_enum :stock_adjustment_types, %i[increase decrease automatic]
  end
end
