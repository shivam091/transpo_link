# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/user_spec.rb

require "spec_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:admin, :confirmed) }

  describe "attributes" do
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
    it { is_expected.to have_db_column(:role_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:is_banned).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:email).unique }
    it { is_expected.to have_db_index(:confirmation_token).unique }
    it { is_expected.to have_db_index(:reset_password_token).unique }
    it { is_expected.to have_db_index(:role_id) }
    it { is_expected.to have_db_index(:unlock_token).unique }
    it { is_expected.to have_db_index(:is_active) }
    it { is_expected.to have_db_index(:is_banned) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:role_id).with_name(:fk_users_role_id_on_roles).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_users_email_presence).with_expression("email IS NOT NULL AND email::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_users_email_length).with_expression("char_length(email::text) <= 55 AND char_length(email::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_users_encrypted_password_presence).with_expression("encrypted_password IS NOT NULL AND encrypted_password::text <> ''::text") }
  end
end
