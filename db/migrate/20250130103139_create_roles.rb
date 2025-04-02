# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name, index: {using: :btree, unique: true}
      t.boolean :is_active, default: false

      t.timestamps_with_timezone null: false

      t.check_constraint "name IS NOT NULL AND name <> ''", name: :check_roles_name_presence
      t.check_constraint "CHAR_LENGTH(name) <= 55 AND CHAR_LENGTH(name) >= 2", name: :check_roles_name_length
    end
  end
end
