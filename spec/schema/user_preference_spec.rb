# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/user_preference_spec.rb

require "spec_helper"

RSpec.describe UserPreference, type: :model do
  subject(:user_preference) { build(:user_preference) }

  describe "attributes" do
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:preferred_locale).of_type(:string) }
    it { is_expected.to have_db_column(:preferred_time_zone).of_type(:string) }
    it { is_expected.to have_db_column(:preferred_currency).of_type(:string) }
    it { is_expected.to have_db_column(:preferred_color_scheme).of_type(:enum) }
    it { is_expected.to have_db_column(:preferred_date_format).of_type(:string) }
    it { is_expected.to have_db_column(:preferred_time_format).of_type(:string) }
    it { is_expected.to have_db_column(:preferred_datetime_format).of_type(:string) }
    it { is_expected.to have_db_column(:first_day_of_week).of_type(:string) }
    it { is_expected.to have_db_column(:are_notifications_enabled).of_type(:boolean) }
    it { is_expected.to have_db_column(:enable_keyboard_shortcuts).of_type(:boolean) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:user_id).unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_user_preferences_user_id_on_users).on_delete(:cascade) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_user_preferences_preferred_color_scheme_in_enum_values).with_expression("preferred_color_scheme = ANY (ARRAY['auto'::color_schemes, 'dark'::color_schemes, 'light'::color_schemes])") }
    it { is_expected.to have_check_constraint(:check_user_preferences_preferred_color_scheme_presence).with_expression("preferred_color_scheme IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_user_preferences_preferred_currency_presence).with_expression("preferred_currency IS NOT NULL AND preferred_currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_preferences_preferred_locale_presence).with_expression("preferred_locale IS NOT NULL AND preferred_locale::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_preferences_preferred_time_zone_presence).with_expression("preferred_time_zone IS NOT NULL AND preferred_time_zone::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_user_preferences_preferred_date_format_presence).with_expression("preferred_date_format IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_user_preferences_preferred_time_format_presence).with_expression("preferred_time_format IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_user_preferences_preferred_datetime_format_presence).with_expression("preferred_datetime_format IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_user_preferences_first_day_of_week_presence).with_expression("first_day_of_week IS NOT NULL") }
  end
end
