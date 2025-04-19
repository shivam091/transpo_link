# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/user_preference_spec.rb

require "spec_helper"

RSpec.describe UserPreference, type: :model do
  subject { build(:user_preference) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:user_preference) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
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

    it { is_expected.to have_db_index(:user_id).unique }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_user_preferences_user_id_on_users).on_delete(:cascade) }

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

  describe "enum" do
    it { is_expected.to define_enum_for(:preferred_color_scheme).with_values({auto: "auto", dark: "dark", light: "light"}).backed_by_column_of_type(:enum) }
    it { is_expected.to define_enum_for(:first_day_of_week).with_values({sunday: "sunday", monday: "monday", saturday: "saturday"}).backed_by_column_of_type(:string) }
  end

  describe "default values" do
    let(:user_preference) { described_class.new }

    it "should set en as default value for #preferred_locale" do
      expect(user_preference.preferred_locale).to eq("en")
    end

    it "should set Asia/Kolkata as default value for #preferred_time_zone" do
      expect(user_preference.preferred_time_zone).to eq("Mumbai")
    end

    it "should set INR as default value for #preferred_currency" do
      expect(user_preference.preferred_currency).to eq("INR")
    end

    it "should set auto as default value for #preferred_color_scheme" do
      expect(user_preference.preferred_color_scheme).to eq("auto")
    end

    it "should set long as default value for #preferred_date_format" do
      expect(user_preference.preferred_date_format).to eq("long")
    end

    it "should set twenty_four_hours_long as default value for #preferred_time_format" do
      expect(user_preference.preferred_time_format).to eq("twenty_four_hours_long")
    end

    it "should set long_with_seconds as default value for #preferred_datetime_format" do
      expect(user_preference.preferred_datetime_format).to eq("long_with_seconds")
    end

    it "should set sunday as default value for #first_day_of_week" do
      expect(user_preference.first_day_of_week).to eq("sunday")
    end

    it "should set true as default value for #are_notifications_enabled" do
      expect(user_preference.are_notifications_enabled).to be_truthy
    end

    it "should set true as default value for #enable_keyboard_shortcuts" do
      expect(user_preference.enable_keyboard_shortcuts).to be_truthy
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:user_preference).touch }
  end

  describe "validations" do
    describe "#user_id" do
      it { is_expected.to validate_presence_of(:user_id) }
    end

    describe "#preferred_locale" do
      it { is_expected.to validate_presence_of(:preferred_locale) }
      it { is_expected.to validate_inclusion_of(:preferred_locale).in_array(I18n.available_locales.map(&:to_s)) }
    end

    describe "#preferred_time_zone" do
      it { is_expected.to validate_presence_of(:preferred_time_zone) }
    end

    describe "#preferred_currency" do
      it { is_expected.to validate_presence_of(:preferred_currency) }
    end

    describe "#preferred_color_scheme" do
      it { is_expected.to validate_presence_of(:preferred_color_scheme) }
      it { is_expected.to validate_inclusion_of(:preferred_color_scheme).in_array(described_class.preferred_color_schemes.values) }
    end
  end
end
