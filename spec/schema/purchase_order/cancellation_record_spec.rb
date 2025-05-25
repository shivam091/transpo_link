# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/purchase_order/cancellation_record_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::CancellationRecord, type: :model do
  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:cancellable_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:cancellable_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:reason).of_type(:enum) }
    it { is_expected.to have_db_column(:note).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index([:cancellable_type, :cancellable_id]).unique }
    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index(:reason) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_po_cancellation_records_user_id_on_users).on_delete(:nullify) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_po_cancellation_records_note_length).with_expression("char_length(note) <= 1000") }
    it { is_expected.to have_check_constraint(:check_po_cancellation_records_reason_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_po_cancellation_records_note_presence).with_expression("reason <> 'OTHER'::po_cancellation_reasons OR note IS NOT NULL AND note <> ''::text") }
    it { is_expected.to have_check_constraint(:check_po_cancellation_records_note_length).with_expression("char_length(note) <= 1000") }
  end
end
