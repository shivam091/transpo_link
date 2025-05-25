# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order/cancellation_record_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::CancellationRecord, type: :model do
  subject(:po_cancellation) { build(:po_cancellation) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:po_cancellation) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:reason).backed_by_column_of_type(:enum) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:note) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:note) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:cancellable).inverse_of(:cancellation_record) }
    it { is_expected.to belong_to(:user).inverse_of(:cancellation_records) }
  end

  describe "validations" do
    describe "#reason" do
      it { is_expected.to validate_presence_of(:reason) }

      it "allows valid reason values" do
        described_class.reasons.keys.each do |reason|
          expect(build(:po_cancellation, reason:)).to be_valid
        end
      end

      it "raises error on invalid reason value" do
        expect {
          build(:po_cancellation, reason: "invalid_reason")
        }.to raise_error(ArgumentError, /is not a valid reason/)
      end
    end

    describe "#note" do
      it { is_expected.to validate_length_of(:note).is_at_most(1000) }
    end
  end

  describe "instance methods" do
    describe "#note_required_if_reason_is_other" do
      let(:po_cancellation) { build(:po_cancellation, reason: :other, note: note) }

      context "when note is blank" do
        let(:note) { "" }

        it "is invalid" do
          po_cancellation.validate

          expect(po_cancellation.errors[:note]).to include("is required")
        end
      end

      context "when note is present" do
        let(:note) { "Item not required" }

        it "is valid" do
          po_cancellation.validate

          expect(po_cancellation.errors[:note]).to be_empty
        end
      end
    end
  end
end
