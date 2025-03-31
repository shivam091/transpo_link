# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.string :email, index: {using: :btree, unique: true}
      t.string :encrypted_password

      ## Recoverable
      t.string :reset_password_token, index: {using: :btree, unique: true}
      t.timestamptz :reset_password_sent_at

      ## Rememberable
      t.timestamptz :remember_created_at

      ## Trackable
      t.integer :sign_in_count, default: 0
      t.timestamptz :current_sign_in_at
      t.timestamptz :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      ## Confirmable
      t.string :confirmation_token, index: {using: :btree, unique: true}
      t.timestamptz :confirmed_at
      t.timestamptz :confirmation_sent_at
      t.string :unconfirmed_email

      ## Lockable
      t.integer :failed_attempts, default: 0
      t.string :unlock_token, index: {using: :btree, unique: true}
      t.timestamptz :locked_at

      ## Additional attributes
      t.timestamptz :last_activity_at
      t.timestamptz :password_updated_at
      t.boolean :is_active, default: false, index: {using: :btree}
      t.boolean :is_banned, default: false, index: {using: :btree}
      t.references :role,
                   type: :uuid,
                   foreign_key: {
                     to_table: :roles,
                     name: :fk_users_role_id_on_roles,
                     on_delete: :restrict
                   },
                   null: false,
                   index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.check_constraint "email IS NOT NULL AND email  <> ''", name: :check_users_email_presence
      t.check_constraint "encrypted_password IS NOT NULL AND encrypted_password  <> ''", name: :check_users_encrypted_password_presence
      t.check_constraint "CHAR_LENGTH(email) <= 55 AND CHAR_LENGTH(email) >= 2", name: :check_users_email_length
    end
  end
end
