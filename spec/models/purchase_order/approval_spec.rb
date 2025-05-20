# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order/approval_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::Approval, type: :model do
  subject(:purchase_order_approval) { build(:purchase_order_approval) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:purchase_order_approval) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:remarks) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:reference_document) }
    it { is_expected.to sanitize_attribute(:remarks) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:purchase_order).inverse_of(:approval) }
  end

  describe "validations" do
    describe "#reference_document" do
      it { is_expected.to validate_presence_of(:reference_document) }
      it { is_expected.to validate_length_of(:reference_document).is_at_most(55) }
    end

    describe "#expected_delivery_date" do
      it { is_expected.to validate_presence_of(:expected_delivery_date) }
      it { is_expected.to validate_comparison_of(:expected_delivery_date).is_greater_than_or_equal_to(Date.current).with_message("must be today or a future date") }
    end

    describe "#remarks" do
      it { is_expected.to validate_length_of(:remarks).is_at_most(1000).allow_blank }
    end
  end

  describe "instance methods" do
    describe "#expected_delivery_date_within_six_months" do
      let(:approval) { build(:purchase_order_approval, expected_delivery_date: delivery_date) }

      context "when expected_delivery_date is today" do
        let(:delivery_date) { Date.current }

        it "is valid" do
          expect(approval).to be_valid
        end
      end

      context "when expected_delivery_date is within 180 days" do
        let(:delivery_date) { Date.current + 179.days }

        it "is valid" do
          expect(approval).to be_valid
        end
      end

      context "when expected_delivery_date is exactly 180 days from today" do
        let(:delivery_date) { Date.current + 180.days }

        it "is valid" do
          expect(approval).to be_valid
        end
      end

      context "when expected_delivery_date is more than 180 days from today" do
        let(:delivery_date) { Date.current + 181.days }

        it "is invalid" do
          expect(approval).to be_invalid
          expect(approval.errors[:expected_delivery_date]).to include("must be within 6 months from today")
        end
      end
    end
  end
end
