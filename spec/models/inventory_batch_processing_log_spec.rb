# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_batch_processing_log_spec.rb

require "spec_helper"

RSpec.describe InventoryBatchProcessingLog, type: :model do
  subject { build(:inventory_batch_processing_log) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_batch_processing_log) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_batch_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:status).of_type(:enum) }
    it { is_expected.to have_db_column(:error_message).of_type(:text) }
    it { is_expected.to have_db_column(:metadata).of_type(:jsonb).with_options(default: {}) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:inventory_batch_id) }
    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index(:status) }
    it { is_expected.to have_db_index(:metadata) }
    it { is_expected.to have_db_index([:inventory_batch_id, :user_id]) }

    it { is_expected.to have_foreign_key(:inventory_batch_id).with_name(:fk_inventory_batch_processing_logs_inventory_batch_id_on_invent).on_delete(:nullify) }
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_inventory_batch_processing_logs_user_id_on_users).on_delete(:nullify) }

    it { is_expected.to have_check_constraint(:check_inventory_batch_processing_logs_error_message_length).with_expression("char_length(error_message) <= 2000") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_processing_logs_status_presence).with_expression("status IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_processing_logs_status_in_enum_values) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum) }
  end

  describe "default values" do
    let(:inventory_batch_processing_log) { described_class.new }

    it "should set pending as default value for #status" do
      expect(inventory_batch_processing_log.status).to eq("pending")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory_batch).inverse_of(:inventory_batch_processing_logs) }
    it { is_expected.to belong_to(:user).inverse_of(:inventory_batch_processing_logs) }
  end

  describe "validations" do
    describe "#error_message" do
      it { is_expected.to validate_length_of(:error_message).is_at_most(2000).allow_blank }
    end

    describe "#status" do
      it { is_expected.to validate_presence_of(:status) }
    end
  end
end
