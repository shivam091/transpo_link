# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateAccessControlModules < ActiveRecord::Migration[8.0]
  def change
    create_table :access_control_modules, id: :uuid do |t|
      t.string :label_key, index: {using: :btree, unique: true}
      t.integer :position, index: {using: :btree, unique: true}
      t.boolean :is_active, default: false, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.check_constraint "label_key IS NOT NULL AND label_key <> ''", name: :check_access_control_modules_label_key_presence
      t.check_constraint "CHAR_LENGTH(label_key) <= 55", name: :check_access_control_modules_label_key_length

      t.check_constraint "position IS NOT NULL", name: :check_access_control_modules_position_presence
      t.check_constraint "position > 0", name: :check_access_control_modules_position_positive
    end
  end
end
