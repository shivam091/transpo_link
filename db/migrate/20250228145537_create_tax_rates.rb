# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateTaxRates < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :tax_rates, id: :uuid do |t|
      t.string :country
      t.string :tax_identifier_type
      t.enum :tax_type, enum_type: :tax_types
      t.enum :business_category, enum_type: :business_categories
      t.decimal :rate, precision: 5, scale: 2
      t.date :valid_from
      t.date :valid_to
      t.timestamps_with_timezone null: false

      t.index :tax_type, using: :btree
      t.index :valid_from, using: :btree
      t.index :valid_to, using: :btree, where: "valid_to IS NULL"
      t.index [:country, :tax_identifier_type], using: :btree
      t.index [:tax_identifier_type, :country, :tax_type, :business_category, :valid_from], using: :btree, unique: true

      t.check_constraint "country IS NOT NULL AND country <> ''", name: :check_tax_rates_country_presence

      t.check_constraint "tax_identifier_type IS NOT NULL AND tax_identifier_type <> ''", name: :check_tax_rates_tax_identifier_type_presence

      t.check_constraint "tax_type IS NOT NULL", name: :check_tax_rates_tax_type_presence
      t.check_constraint "tax_type IN (#{enum_values('tax_types')})", name: :check_tax_rates_tax_type_inclusion

      t.check_constraint "business_category IS NOT NULL", name: :check_tax_rates_business_category_presence
      t.check_constraint "business_category IN (#{enum_values('business_categories')})", name: :check_tax_rates_business_category_inclusion

      t.check_constraint "rate IS NOT NULL", name: :check_tax_rates_rate_presence
      t.check_constraint "rate >= 0.0 AND rate <= 100.0", name: :check_tax_rates_rate_numericality

      t.check_constraint "valid_from IS NOT NULL", name: :check_tax_rates_valid_from_presence
      t.check_constraint "valid_from >= CURRENT_DATE", name: :check_tax_rates_valid_from_future

      t.check_constraint "valid_to IS NULL OR valid_to > valid_from", name: :check_tax_rates_valid_to_comparison
    end
  end
end
