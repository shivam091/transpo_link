# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateAccessControlRolePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :access_control_role_permissions, id: :uuid do |t|
      t.references :role,
                   type: :uuid,
                   foreign_key: {
                     to_table: :roles,
                     name: :fk_access_control_role_permissions_action_id_on_roles,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.references :permission,
                   type: :uuid,
                   foreign_key: {
                     to_table: :access_control_permissions,
                     name: :fk_access_control_role_permissions_permission_id_on_permissions,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.boolean :is_allowed, default: true, index: {using: :btree}
      t.boolean :is_active, default: false, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.index [:role_id, :permission_id], using: :btree, unique: true
    end
  end
end
