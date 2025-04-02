# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateWarehouses < ActiveRecord::Migration[8.0]
  def change
    create_table :warehouses, id: :uuid do |t|
      t.string :name
      t.string :reference_code, index: {using: :btree, unique: true}
      t.string :email_address, index: {using: :btree, unique: true}
      t.string :contact_number
      t.text :description
      t.decimal :total_capacity, precision: 12, scale: 2
      t.string :capacity_unit
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.boolean :is_active, default: false, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.check_constraint "name IS NOT NULL AND name <> ''", name: :check_warehouses_name_presence
      t.check_constraint "total_capacity IS NOT NULL", name: :check_warehouses_total_capacity_presence
      t.check_constraint "capacity_unit IS NOT NULL AND capacity_unit <> ''", name: :check_warehouses_capacity_unit_presence

      t.check_constraint "CHAR_LENGTH(name) <= 255 AND CHAR_LENGTH(name) >= 2", name: :check_warehouses_name_length
      t.check_constraint "CHAR_LENGTH(description) <= 1000", name: :check_warehouses_description_length
      t.check_constraint "CHAR_LENGTH(email_address) <= 55 AND CHAR_LENGTH(email_address) >= 2", name: :check_warehouses_email_address_length
      t.check_constraint "CHAR_LENGTH(contact_number) <= 55 AND CHAR_LENGTH(contact_number) >= 2", name: :check_warehouses_contact_number_length

      t.check_constraint "total_capacity BETWEEN 0.0 AND 100000000000.0", name: :check_warehouses_total_capacity_range
      t.check_constraint "latitude BETWEEN -90.0 AND 90.0", name: :check_warehouses_latitude_range
      t.check_constraint "longitude BETWEEN -180.0 AND 180.0", name: :check_warehouses_longitude_range
    end
  end
end
