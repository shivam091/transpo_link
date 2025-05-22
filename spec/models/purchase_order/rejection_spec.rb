# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order/rejection_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::Rejection, type: :model do
  subject(:purchase_order_rejection) { build(:purchase_order_rejection) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:purchase_order_rejection) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:reason).backed_by_column_of_type(:enum) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:suggested_alternatives) }
    it { is_expected.to nullify_if_blank(:note) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:suggested_alternatives) }
    it { is_expected.to sanitize_attribute(:note) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:purchase_order).inverse_of(:rejection) }
  end

  describe "validations" do
    describe "#reason" do
      it { is_expected.to validate_presence_of(:reason) }

      it "allows valid shipping_method values" do
        described_class.reasons.values.each do |reason|
          expect(build(:purchase_order_rejection, reason:)).to be_valid
        end
      end

      it "raises error on invalid shipping_method value" do
        expect {
          build(:purchase_order_rejection, reason: "invalid_reason")
        }.to raise_error(ArgumentError, /is not a valid reason/)
      end
    end

    describe "#suggested_alternatives" do
      it { is_expected.to validate_length_of(:suggested_alternatives).is_at_most(1000).allow_blank }
    end

    describe "#note" do
      it { is_expected.to validate_length_of(:note).is_at_most(1000).allow_blank }
    end
  end

  describe "instance methods" do
    describe "#reject_purchase_order!" do
      let!(:purchase_order) { create(:purchase_order) }

      it "calls PurchaseOrders::RejectService after create" do
        expect(PurchaseOrders::RejectService).to receive(:call).with(purchase_order)

        create(:purchase_order_rejection, purchase_order: purchase_order)
      end
    end
  end
end
