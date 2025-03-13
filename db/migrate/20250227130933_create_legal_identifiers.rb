# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateLegalIdentifiers < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :legal_identifiers, id: :uuid do |t|
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_legal_identifiers_user_id_on_users,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.string :country
      t.enum :entity_type, enum_type: :entity_types
      t.string :tax_identifier_type
      t.string :tax_identifier
      t.string :business_identifier_type
      t.string :business_identifier
      t.timestamps_with_timezone null: false

      t.index [:tax_identifier, :tax_identifier_type, :country, :entity_type], unique: true, using: :btree
      t.index [:business_identifier, :business_identifier_type, :country], unique: true, using: :btree
      t.index :entity_type, using: :btree

      t.check_constraint "tax_identifier_type IS NOT NULL AND tax_identifier_type <> ''", name: :check_legal_identifiers_tax_identifier_type_presence
      t.check_constraint "tax_identifier IS NOT NULL AND tax_identifier <> ''", name: :check_legal_identifiers_tax_identifier_presence
      t.check_constraint "country IS NOT NULL AND country <> ''", name: :check_legal_identifiers_country_presence
      t.check_constraint "entity_type IS NOT NULL", name: :check_legal_identifiers_entity_type_presence

      t.check_constraint "entity_type IN (#{enum_values('entity_types')})", name: :check_legal_identifiers_entity_type_inclusion

      # business_identifier presence based on entity_type
      t.check_constraint "(
        (entity_type = 'business' AND business_identifier IS NOT NULL AND business_identifier <> '')
        OR (entity_type = 'individual' AND business_identifier IS NULL)
      )", name: :check_legal_identifiers_business_identifier_based_on_entity

      # business_identifier_type presence based on entity_type
      t.check_constraint "(
        (entity_type = 'business' AND business_identifier_type IS NOT NULL AND business_identifier_type <> '')
        OR (entity_type = 'individual' AND business_identifier_type IS NULL)
      )", name: :check_legal_identifiers_business_identifier_type_based_on_entity
    end
  end
end
