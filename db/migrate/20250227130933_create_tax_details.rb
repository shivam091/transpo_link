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
      t.enum :entity_type, enum_type: :entity_types
      t.enum :tax_type, enum_type: :tax_types
      t.string :tax_number
      t.enum :business_number_type, enum_type: :business_number_types
      t.string :business_number
      t.string :country
      t.timestamps_with_timezone null: false

      t.index [:tax_number, :tax_type, :country, :entity_type], unique: true, using: :btree
      t.index [:business_number, :business_number_type, :country], unique: true, using: :btree
      t.index :entity_type, using: :btree

      t.check_constraint "tax_type IS NOT NULL", name: "check_tax_details_tax_type_presence"
      t.check_constraint "tax_number IS NOT NULL AND tax_number <> ''", name: "check_tax_details_tax_number_presence"
      t.check_constraint "country IS NOT NULL AND country <> ''", name: "check_tax_details_country_presence"
      t.check_constraint "entity_type IS NOT NULL", name: "check_tax_details_entity_type_presence"

      t.check_constraint "tax_type IN (#{enum_values('tax_types')})", name: "check_tax_details_tax_type_inclusion"
      t.check_constraint "entity_type IN (#{enum_values('entity_types')})", name: "check_tax_details_entity_type_inclusion"
      t.check_constraint "business_number_type IN (#{enum_values('business_number_types')})", name: "check_tax_details_business_number_type_inclusion"

      # business_number presence based on entity_type
      t.check_constraint "(
        (entity_type = 'business' AND business_number IS NOT NULL AND business_number <> '')
        OR (entity_type = 'individual' AND business_number IS NULL)
      )", name: "check_tax_details_business_number_based_on_entity"

      # business_number_type presence based on entity_type
      t.check_constraint "(
        (entity_type = 'business' AND business_number_type IS NOT NULL)
        OR (entity_type = 'individual' AND business_number_type IS NULL)
      )", name: "check_tax_details_business_number_type_based_on_entity"
    end
  end

  private

  def enum_values(enum_name)
    ActiveRecord::Base.connection.execute("SELECT enumlabel FROM pg_enum JOIN pg_type ON pg_enum.enumtypid = pg_type.oid WHERE typname = '#{enum_name}'").map do |row|
      "'#{row['enumlabel']}'"
    end.join(", ")
  end
end
