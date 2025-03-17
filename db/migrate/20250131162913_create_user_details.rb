# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateUserDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :user_details, primary_key: :user_id, id: false do |t|
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: :fk_user_details_user_id_on_users,
                     on_delete: :cascade
                   },
                   null: false,
                   primary_key: true,
                   index: {using: :btree, unique: true}
      t.string :first_name
      t.string :last_name
      t.string :mobile_number, index: {using: :btree, unique: true}
      t.string :alternate_contact_number
      t.string :alternate_email
      t.timestamps_with_timezone null: false

      t.check_constraint "first_name IS NOT NULL AND first_name  <> ''", name: :check_user_details_first_name_presence
      t.check_constraint "last_name IS NOT NULL AND last_name  <> ''", name: :check_user_details_last_name_presence

      t.check_constraint "CHAR_LENGTH(first_name) <= 55 AND CHAR_LENGTH(first_name) >= 2", name: :check_user_details_first_name_length
      t.check_constraint "CHAR_LENGTH(last_name) <= 55 AND CHAR_LENGTH(last_name) >= 2", name: :check_user_details_last_name_length
      t.check_constraint "CHAR_LENGTH(mobile_number) <= 55 AND CHAR_LENGTH(mobile_number) >= 2", name: :check_user_details_mobile_number_length
      t.check_constraint "CHAR_LENGTH(alternate_contact_number) <= 55 AND CHAR_LENGTH(alternate_contact_number) >= 2", name: :check_user_details_alternate_contact_number_length
      t.check_constraint "CHAR_LENGTH(alternate_email) <= 55 AND CHAR_LENGTH(alternate_email) >= 2", name: :check_user_details_alternate_email_length
    end
  end
end
