# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/user_preference_spec.rb

require "spec_helper"

RSpec.describe UserPreference, type: :model do
  subject(:user_preference) { build(:user_preference) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:user_preference) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:user_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:preferred_locale).of_type(:string) }
    it { is_expected.to have_db_column(:preferred_time_zone).of_type(:string) }
    it { is_expected.to have_db_column(:preferred_currency).of_type(:string) }
    it { is_expected.to have_db_column(:preferred_color_scheme).of_type(:enum) }
    it { is_expected.to have_db_column(:are_notifications_enabled).of_type(:boolean) }

    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_user_preferences_user_id_on_users).on_delete(:cascade) }

    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:preferred_color_scheme).with_values({auto: "auto", dark: "dark", light: "light"}).backed_by_column_of_type(:enum) }
  end

  describe "default values" do
    it "should set en as default value for #preferred_locale" do
      expect(user_preference.preferred_locale).to eq("en")
    end

    it "should set Asia/Kolkata as default value for #preferred_time_zone" do
      expect(user_preference.preferred_time_zone).to eq("Asia/Kolkata")
    end

    it "should set INR as default value for #preferred_currency" do
      expect(user_preference.preferred_currency).to eq("INR")
    end

    it "should set auto as default value for #preferred_color_scheme" do
      expect(user_preference.preferred_color_scheme).to eq("auto")
    end

    it "should set true as default value for #are_notifications_enabled" do
      expect(user_preference.are_notifications_enabled).to be_truthy
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:user_preference) }
  end
end
