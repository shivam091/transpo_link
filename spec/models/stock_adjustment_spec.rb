# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/stock_adjustment_spec.rb

require "spec_helper"

RSpec.describe StockAdjustment, type: :model do
  subject(:stock_adjustment) { build(:stock_adjustment) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:stock_adjustment) }
  end

  describe "included modules" do
    it { is_expected.to include_module(ScaleEnforcer) }
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:adjustment_type).backed_by_column_of_type(:enum) }
    it { is_expected.to define_enum_for(:adjustment_reason).backed_by_column_of_type(:enum) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:note) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:note) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:adjusted_quantity) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:adjustable).inverse_of(:stock_adjustments) }
    it { is_expected.to belong_to(:source).inverse_of(:stock_adjustments).optional }
    it { is_expected.to belong_to(:inventory).inverse_of(:stock_adjustments).optional }
    it { is_expected.to belong_to(:user).inverse_of(:stock_adjustments) }
    it { is_expected.to belong_to(:unit).inverse_of(:stock_adjustments) }
  end

  describe "validations" do
    describe "#adjusted_quantity" do
      it { is_expected.to validate_presence_of(:adjusted_quantity) }

      context "when adjusted_quantity is invalid" do
        it "is invalid" do
          stock_adjustment.adjusted_quantity = "abcd"
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjusted_quantity]).to include("must be greater than 0.0")
        end
      end

      context "when adjusted_quantity <= 0.0" do
        it "is invalid" do
          stock_adjustment.adjusted_quantity = 0.0
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjusted_quantity]).to include("must be greater than 0.0")
        end
      end

      context "when adjusted_quantity > 0.0" do
        it "is valid" do
          stock_adjustment.adjusted_quantity = 1.0
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjusted_quantity]).to be_empty
        end
      end
    end

    describe "#adjustment_type" do
      it { is_expected.to validate_presence_of(:adjustment_type) }

      it "allows valid adjustment_type values" do
        described_class.adjustment_types.keys.each do |adjustment_type|
          stock_adjustment = build(:stock_adjustment, adjustment_type:)
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjustment_type]).to be_empty
        end
      end

      it "raises error on invalid adjustment_type value" do
        expect {
          build(:stock_adjustment, adjustment_type: "invalid_adjustment_type")
        }.to raise_error(ArgumentError, /is not a valid adjustment_type/)
      end
    end

    describe "#adjustment_reason" do
      it { is_expected.to validate_presence_of(:adjustment_reason) }

      it "allows valid adjustment_reason values" do
        described_class.adjustment_reasons.keys.each do |adjustment_reason|
          stock_adjustment = build(:stock_adjustment, adjustment_reason:)
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjustment_reason]).to be_empty
        end
      end

      it "raises error on invalid adjustment_reason value" do
        expect {
          build(:stock_adjustment, adjustment_reason: "invalid_adjustment_reason")
        }.to raise_error(ArgumentError, /is not a valid adjustment_reason/)
      end
    end

    describe "#note" do
      it { is_expected.to validate_length_of(:note).is_at_most(1000).allow_blank }
    end
  end
end
