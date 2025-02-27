# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateTaxDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :tax_details, id: :uuid do |t|
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: "fk_tax_details_user_id_on_users",
                     on_delete: :cascade
                   },
                   index: {using: "btree"}
      t.enum :tax_type, enum_type: :tax_types
      t.string :tax_number
      t.string :country
      t.timestamps_with_timezone null: false

      t.index [:tax_number, :tax_type, :country], using: :btree, unique: true

      t.check_constraint "tax_type IS NOT NULL", name: "check_tax_details_tax_type_presence"
      t.check_constraint "tax_number IS NOT NULL AND tax_number <> ''", name: "check_tax_details_tax_number_presence"

      t.check_constraint "tax_type IN (#{all_tax_types})", name: "check_tax_details_tax_type_inclusion"
      t.check_constraint "country IS NOT NULL OR tax_type NOT IN (#{country_requiring_tax_types})", name: "check_tax_details_tax_type_requires_country"
    end
  end

  private

  def all_tax_types
    TaxDetail.tax_types.values.map { |v| "'#{v}'" }.join(", ")
  end

  def country_requiring_tax_types
    TaxDetail::COUNTRY_REQUIRING_TAX_TYPES.map { |v| "'#{v}'" }.join(", ")
  end
end
