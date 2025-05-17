# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateAccessControlActions < ActiveRecord::Migration[8.0]
  def change
    create_table :access_control_actions, id: :uuid do |t|
      t.string :label_key, index: {using: :btree, unique: true}
      t.boolean :is_active, default: false, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.check_constraint "label_key IS NOT NULL AND label_key <> ''", name: :check_access_control_actions_label_key_presence
      t.check_constraint "CHAR_LENGTH(label_key) <= 55", name: :check_access_control_actions_label_key_length
    end
  end
end
