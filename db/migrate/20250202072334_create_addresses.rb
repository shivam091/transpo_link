# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses, id: :uuid do |t|
      t.references :addressable,
                   type: :uuid,
                   polymorphic: true,
                   index: {using: :btree}
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.timestamps_with_timezone null: false

      t.check_constraint "address1 IS NOT NULL AND address1  <> ''", name: "check_addresses_address1_presence"
      t.check_constraint "country IS NOT NULL AND country  <> ''", name: "check_addresses_country_presence"
      t.check_constraint "CHAR_LENGTH(address1) <= 100", name: "check_addresses_address1_length"
      t.check_constraint "CHAR_LENGTH(address2) <= 100", name: "check_addresses_address2_length"
      t.check_constraint "CHAR_LENGTH(postal_code) <= 20", name: "check_addresses_postal_code_length"
    end
  end
end
