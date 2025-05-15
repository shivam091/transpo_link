# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateAccessControlPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :access_control_permissions, id: :uuid do |t|
      t.references :action,
                   type: :uuid,
                   foreign_key: {
                     to_table: :access_control_actions,
                     name: :fk_access_control_permissions_action_id_on_access_control_actions,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.references :module,
                   type: :uuid,
                   foreign_key: {
                     to_table: :access_control_modules,
                     name: :fk_access_control_permissions_module_id_on_access_control_modules,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.boolean :is_active, default: false, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.index [:action_id, :module_id], using: :btree, unique: true
    end
  end
end
