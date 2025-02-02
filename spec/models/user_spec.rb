# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/user_spec.rb

require "spec_helper"

RSpec.describe User, type: :model do
subject(:user) { build(:admin, :confirmed) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:admin) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:encrypted_password).of_type(:string) }
    it { is_expected.to have_db_column(:reset_password_token).of_type(:string) }
    it { is_expected.to have_db_column(:reset_password_sent_at).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:remember_created_at).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:sign_in_count).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:current_sign_in_at).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:last_sign_in_at).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:current_sign_in_ip).of_type(:inet) }
    it { is_expected.to have_db_column(:last_sign_in_ip).of_type(:inet) }
    it { is_expected.to have_db_column(:confirmation_token).of_type(:string) }
    it { is_expected.to have_db_column(:confirmed_at).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:confirmation_sent_at).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:unconfirmed_email).of_type(:string) }
    it { is_expected.to have_db_column(:failed_attempts).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:unlock_token).of_type(:string) }
    it { is_expected.to have_db_column(:locked_at).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:role_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:is_banned).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:email).unique(true) }
    it { is_expected.to have_db_index(:confirmation_token).unique(true) }
    it { is_expected.to have_db_index(:reset_password_token).unique(true) }
    it { is_expected.to have_db_index(:role_id) }
    it { is_expected.to have_db_index(:unlock_token).unique(true) }
    it { is_expected.to have_db_index(:is_active) }
    it { is_expected.to have_db_index(:is_banned) }

    it { is_expected.to have_foreign_key(:role_id).with_name(:fk_users_role_id_on_roles).on_delete(:restrict) }

    it { is_expected.to have_check_constraint("check_users_email_presence").with_expression("email IS NOT NULL AND email::text <> ''::text") }
    it { is_expected.to have_check_constraint("check_users_email_length").with_expression("char_length(email::text) <= 55 AND char_length(email::text) >= 2") }
    it { is_expected.to have_check_constraint("check_users_encrypted_password_presence").with_expression("encrypted_password IS NOT NULL AND encrypted_password::text <> ''::text") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(CaseSensitivity) }
  end

  describe "default values" do
    it "should set false as default value for #is_banned" do
      expect(user.is_banned).to be_falsy
    end

    it "should set false as default value for #is_active" do
      expect(user.is_active).to be_falsy
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:user_detail).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_one(:user_preference).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_many(:request_logs).inverse_of(:user).dependent(:nullify) }

    it { is_expected.to belong_to(:role).inverse_of(:users) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:name).to(:role).with_prefix }
    it { is_expected.to delegate_method(:full_name).to(:user_detail) }
    it { is_expected.to delegate_method(:mobile_number).to(:user_detail) }
    it { is_expected.to delegate_method(:alternate_contact_number).to(:user_detail) }
    it { is_expected.to delegate_method(:alternate_email).to(:user_detail) }
    it { is_expected.to delegate_method(:preferred_locale).to(:user_preference) }
    it { is_expected.to delegate_method(:preferred_time_zone).to(:user_preference) }
    it { is_expected.to delegate_method(:preferred_color_scheme).to(:user_preference) }
    it { is_expected.to delegate_method(:preferred_currency).to(:user_preference) }
    it { is_expected.to delegate_method(:are_notifications_enabled).to(:user_preference) }
  end
end
