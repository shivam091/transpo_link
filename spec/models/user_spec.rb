# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/user_spec.rb

require "spec_helper"

RSpec.describe User, type: :model do
  let!(:dummy_password) { Rails.application.credentials.config[:TEST_PASSWORD] }

  subject { create(:admin, :confirmed) }

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
    it { is_expected.to have_db_column(:role_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:is_banned).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:email).unique }
    it { is_expected.to have_db_index(:confirmation_token).unique }
    it { is_expected.to have_db_index(:reset_password_token).unique }
    it { is_expected.to have_db_index(:role_id) }
    it { is_expected.to have_db_index(:unlock_token).unique }
    it { is_expected.to have_db_index(:is_active) }
    it { is_expected.to have_db_index(:is_banned) }

    it { is_expected.to have_foreign_key(:role_id).with_name(:fk_users_role_id_on_roles).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_users_email_presence).with_expression("email IS NOT NULL AND email::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_users_email_length).with_expression("char_length(email::text) <= 55 AND char_length(email::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_users_encrypted_password_presence).with_expression("encrypted_password IS NOT NULL AND encrypted_password::text <> ''::text") }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LAST_ACTIVITY_AT_INTERVAL).with_value(2.minutes) }
    it { is_expected.to have_constant(:THROTTLE_RESET_PERIOD).with_value(2.minutes) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(CaseSensitivity) }
    it { is_expected.to include_module(WithoutTimestamps) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sanitizable) }
  end

  describe "default values" do
    let(:user) { described_class.new }

    it "should set false as default value for #is_banned" do
      expect(user.is_banned).to be_falsy
    end
  end

  describe "normalized attributes" do
    it { is_expected.to normalize(:email).from("  test@example.com  ").to("test@example.com") }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:email) }
    it { is_expected.to sanitize_attribute(:password) }
    it { is_expected.to sanitize_attribute(:password_confirmation) }
  end

  describe "associations" do
    it { is_expected.to have_one(:user_detail).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_one(:user_preference).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_one(:address).inverse_of(:addressable).dependent(:destroy) }

    it { is_expected.to have_many(:request_logs).inverse_of(:user).dependent(:nullify) }
    it { is_expected.to have_many(:legal_identifiers).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_many(:inventory_audit_logs).inverse_of(:user).dependent(:nullify) }
    it { is_expected.to have_many(:feedbacks).inverse_of(:user).dependent(:nullify) }
    it { is_expected.to have_many(:purchase_orders).inverse_of(:manager).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:supplied_purchase_orders).inverse_of(:supplier).class_name("PurchaseOrder").dependent(:restrict_with_exception) }

    it { is_expected.to have_many(:warehouse_managers).inverse_of(:manager).with_foreign_key(:manager_id).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:managed_warehouses).through(:warehouse_managers).inverse_of(:managers).source(:warehouse) }
    it { is_expected.to have_many(:warehouse_suppliers).inverse_of(:supplier).with_foreign_key(:supplier_id).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:supplied_warehouses).through(:warehouse_suppliers).inverse_of(:suppliers).source(:warehouse) }

    it { is_expected.to belong_to(:role).inverse_of(:users) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:after, :update, :update_password_updated_at) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:name).to(:role).with_prefix }
    it { is_expected.to delegate_method(:full_name).to(:user_detail) }
    it { is_expected.to delegate_method(:first_name).to(:user_detail) }
    it { is_expected.to delegate_method(:last_name).to(:user_detail) }
    it { is_expected.to delegate_method(:mobile_number).to(:user_detail) }
    it { is_expected.to delegate_method(:alternate_contact_number).to(:user_detail) }
    it { is_expected.to delegate_method(:alternate_email).to(:user_detail) }
    it { is_expected.to delegate_method(:preferred_locale).to(:user_preference) }
    it { is_expected.to delegate_method(:preferred_time_zone).to(:user_preference) }
    it { is_expected.to delegate_method(:preferred_color_scheme).to(:user_preference) }
    it { is_expected.to delegate_method(:preferred_currency).to(:user_preference) }
    it { is_expected.to delegate_method(:are_notifications_enabled).to(:user_preference) }
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:address).update_only(true) }
    it { is_expected.to accept_nested_attributes_for(:user_detail).update_only(true) }
    it { is_expected.to accept_nested_attributes_for(:user_preference).update_only(true) }
  end

  describe "validations" do
    describe "#email" do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
      it { is_expected.to allow_value("abc@email.com").for(:email) }
      it { is_expected.to_not allow_value("abc").for(:email) }

      it "validates the length of email" do
        expect(build(:buyer, email: "ab@example.com")).to be_valid # 6 characters, within range
        expect(build(:buyer, email: "#{"a" * 56}@example.com")).to be_invalid # Too long
      end
    end

    describe "#password" do
      context "when password is required" do
        before { allow(subject).to receive(:password_required?) { true } }

        it { is_expected.to validate_presence_of(:password) }
        it { is_expected.to validate_length_of(:password).is_at_least(8).is_at_most(20) }
      end

      context "when password is not required" do
        before { allow(subject).to receive(:password_required?) { false } }

        it { is_expected.to_not validate_presence_of(:password) }
      end

      context "when password is present and not password_confirmation" do
        before do
          allow(subject).to receive(:password) { dummy_password }
          allow(subject).to receive(:password_confirmation) { "" }
        end

        it { is_expected.to be_invalid }
      end

      context "when both password and password_confirmation are present" do
        before do
          allow(subject).to receive(:password) { dummy_password }
          allow(subject).to receive(:password_confirmation) { dummy_password }
        end

        it { is_expected.to be_valid }
      end
    end

    describe "#role_id" do
      it { is_expected.to validate_presence_of(:role_id) }
    end
  end

  describe "scopes" do
    let(:admin) { create(:admin, :confirmed, :active) }
    let(:buyer) { create(:buyer, :confirmed, :active) }
    let(:supplier) { create(:supplier, :confirmed, :active) }
    let(:manager) { create(:manager, :confirmed, :active, :suspended) }

    describe ".admins" do
      it "returns array of admins" do
        expect(admin).to be_one_of(described_class.admins)
      end
    end

    describe ".suppliers" do
      it "returns array of suppliers" do
        expect(supplier).to be_one_of(described_class.suppliers)
      end
    end

    describe ".buyers" do
      it "returns array of buyers" do
        expect(buyer).to be_one_of(described_class.buyers)
      end
    end

    describe ".managers" do
      it "returns array of managers" do
        expect(manager).to be_one_of(described_class.managers)
      end
    end

    describe ".suspended" do
      it "returns array of suspended users" do
        expect(manager).to be_one_of(described_class.suspended)
      end
    end
  end

  describe "class methods" do
    describe ".with_email" do
      let(:admin) { create(:admin, :confirmed, :active) }

      it "returns user with provided email" do
        expect(described_class.with_email(admin.email)).to eq(admin)
      end
    end

    describe ".select_options" do
      let!(:supplier) { create(:supplier, :confirmed, :active) }

      it "returns array of users for select list" do
        expect(described_class.select_options).to eq([[supplier.full_name, supplier.id]])
      end
    end

    describe ".with_role" do
      let(:buyer) { create(:buyer, :confirmed, :active) }

      it "returns array of users having given role" do
        expect(buyer).to be_one_of(described_class.with_role("buyer"))
      end
    end

    describe ".find_for_database_authentication" do
      let!(:existing_user) { create(:admin) }

      it "finds the user with matching email" do
        expect(described_class.find_for_database_authentication(email: existing_user.email)).to eq(existing_user)
      end

      it "returns nil if email does not match" do
        expect(described_class.find_for_database_authentication(email: "wrong@example.com")).to be_nil
      end

      it "trims whitespace from email before searching" do
        expect(described_class.find_for_database_authentication(email: "  #{existing_user.email}  ")).to eq(existing_user)
      end

      it "ignores attributes other than email" do
        expect(described_class.find_for_database_authentication(email: existing_user.email, is_active: false)).to eq(existing_user)
      end
    end
  end

  describe "instance methods" do
    describe "#active_for_authentication?" do
      it "returns true if the user is active" do
        subject.is_active = true

        expect(subject.active_for_authentication?).to be_truthy
      end

      it "returns false if the user is not active" do
        subject.is_active = false

        expect(subject.active_for_authentication?).to be_falsy
      end
    end

    describe "#update_password_updated_at" do
      let!(:original_timestamp) { subject.password_updated_at }

      context "when the password is updated" do
        it "updates the password_updated_at timestamp" do
          subject.update(password: dummy_password, password_confirmation: dummy_password)
          subject.reload

          expect(subject.password_updated_at).to be > original_timestamp
        end
      end

      context "when other attributes are updated" do
        it "does not change the password_updated_at timestamp" do
          subject.update(email: "new_email@example.com")

          expect(subject.password_updated_at).to eq(original_timestamp)
        end
      end
    end

    describe "#update_last_activity_at" do
      let(:user) { create(:admin, last_activity_at: last_activity_time) }

      context "when the user is new (not saved in the database)" do
        let(:user) { build(:admin) }

        it "does not update last_activity_at" do
          expect { user.update_last_activity_at }.to not_change(user, :last_activity_at)
        end
      end

      context "when last_activity_at is nil" do
        let(:last_activity_time) { nil }

        it "updates last_activity_at to current time" do
          freeze_time do
            expect { user.update_last_activity_at }
              .to change { user.reload.last_activity_at }
              .from(nil).to(Time.now.utc)
          end
        end
      end

      context "when last_activity_at is older than the interval" do
        let(:last_activity_time) { 5.minutes.ago }

        it "updates last_activity_at to current time" do
          freeze_time do
            expect { user.update_last_activity_at }
              .to change { user.reload.last_activity_at }
              .from(last_activity_time).to(Time.now.utc)
          end
        end
      end

      context "when last_activity_at is within the interval" do
        let(:last_activity_time) { 1.minute.ago }

        it "does not update last_activity_at" do
          expect { user.update_last_activity_at }
            .to not_change { user.reload.last_activity_at }
        end
      end
    end

    describe "#recently_sent_password_reset_instructions?" do
      let(:buyer) { create(:buyer, :confirmed) }

      context "when reset_password_sent_at is nil" do
        it "returns false" do
          buyer.reset_password_sent_at = nil

          expect(buyer.recently_sent_password_reset_instructions?).to be_falsy
        end
      end

      context "when reset_password_sent_at is older than the throttle period" do
        it "returns false" do
          buyer.reset_password_sent_at = 3.minutes.ago

          expect(buyer.recently_sent_password_reset_instructions?).to be_falsy
        end
      end

      context "when reset_password_sent_at is within the throttle period" do
        it "returns true" do
          buyer.reset_password_sent_at = 1.minute.ago

          expect(buyer.recently_sent_password_reset_instructions?).to be_truthy
        end
      end
    end

    describe "#admin?" do
      it { expect(subject.admin?).to be_truthy }
      it { expect(subject.supplier?).to be_falsy }
    end

    describe "#buyer?" do
      let(:buyer) { create(:buyer, :confirmed) }

      it { expect(buyer.buyer?).to be_truthy }
      it { expect(buyer.supplier?).to be_falsy }
    end

    describe "#supplier?" do
      let(:supplier) { create(:supplier, :confirmed) }

      it { expect(supplier.supplier?).to be_truthy }
      it { expect(supplier.manager?).to be_falsy }
    end

    describe "#manager?" do
      let(:manager) { create(:manager, :confirmed) }

      it { expect(manager.manager?).to be_truthy }
      it { expect(manager.supplier?).to be_falsy }
    end
  end
end
