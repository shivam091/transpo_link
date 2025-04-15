# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateUnits < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :units, id: :uuid do |t|
      t.enum :category, enum_type: :unit_categories, index: {using: :btree}
      t.string :symbol
      t.timestamps_with_timezone null: false

      t.index [:category, :symbol], using: :btree, unique: true

      t.check_constraint "category IS NOT NULL", name: :check_units_category_presence
      t.check_constraint "category IN (#{enum_values('unit_categories')})", name: :check_units_category_in_enum_values

      t.check_constraint "symbol IS NOT NULL AND symbol <> ''", name: :check_units_symbol_presence
    end
  end
end
