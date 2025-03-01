# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateTaxRates < ActiveRecord::Migration[8.0]
  def change
    create_table :tax_rates, id: :uuid do |t|
      t.string :country
      t.enum :tax_type, enum_type: :tax_types
      t.decimal :rate, precision: 5, scale: 2
      t.date :valid_from
      t.date :valid_to

      t.timestamps_with_timezone null: false

      t.index :valid_from, using: :btree
      t.index :valid_to, using: :btree, where: "valid_to IS NULL"
      t.index [:country, :tax_type], using: :btree
      t.index [:country, :tax_type, :valid_from, :valid_to], using: :btree, unique: true

      t.check_constraint "country IS NOT NULL AND country <> ''", name: "check_tax_rates_country_presence"
      t.check_constraint "tax_type IS NOT NULL", name: "check_tax_rates_tax_type_presence"
      t.check_constraint "rate IS NOT NULL", name: "check_tax_rates_rate_presence"
      t.check_constraint "rate >= 0 AND rate <= 100", name: "check_tax_rates_rate_numericality"
      t.check_constraint "valid_from IS NOT NULL", name: "check_tax_rates_valid_from_presence"
      t.check_constraint "valid_from >= CURRENT_DATE", name: "check_tax_rates_valid_from_future"
      t.check_constraint "valid_to IS NULL OR valid_to > valid_from", name: "check_tax_rates_valid_from_to_comparison"
    end
  end
end
