# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateUserPreferences < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :user_preferences, primary_key: :user_id, id: false do |t|
      t.references :user,
                   type: :uuid,
                   foreign_key: {
                     to_table: :users,
                     name: "fk_user_preferences_user_id_on_users",
                     on_delete: :cascade
                   },
                   null: false,
                   primary_key: true,
                   index: {using: "btree", unique: true}
      t.string :preferred_locale
      t.string :preferred_time_zone
      t.string :preferred_currency
      t.enum :preferred_color_scheme, enum_type: :color_schemes
      t.boolean :are_notifications_enabled
      t.timestamps_with_timezone null: false

      t.check_constraint "preferred_locale IS NOT NULL AND preferred_locale  <> ''", name: "check_user_preferences_preferred_locale_presence"
      t.check_constraint "preferred_time_zone IS NOT NULL AND preferred_time_zone  <> ''", name: "check_user_preferences_preferred_time_zone_presence"
      t.check_constraint "preferred_currency IS NOT NULL AND preferred_currency  <> ''", name: "check_user_preferences_preferred_currency_presence"
      t.check_constraint "preferred_color_scheme IS NOT NULL", name: "check_user_preferences_preferred_color_scheme_presence"
      t.check_constraint "preferred_color_scheme IN (#{enum_values('color_schemes')})", name: "check_user_preferences_preferred_color_scheme_inclusion"
    end
  end
end
