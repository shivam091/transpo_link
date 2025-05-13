# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/stock_spec.rb

require "spec_helper"

RSpec.describe Stock, type: :model do
  subject(:stock) { build(:stock) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:stock) }
  end

  describe "default values" do
    let(:stock) { described_class.new }

    it "should set 0.0 as default value for #quantity_in_hand" do
      expect(stock.quantity_in_hand).to eq(0.0)
    end

    it "should set 0.0 as default value for #quantity_pending_to_buyer" do
      expect(stock.quantity_pending_to_buyer).to eq(0.0)
    end
  end

  describe "included modules" do
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:quantity_in_hand) }
    it { is_expected.to apply_scale_to(:quantity_pending_to_buyer) }
  end

  describe "validations" do
    describe "#quantity_in_hand" do
      it { is_expected.to validate_presence_of(:quantity_in_hand) }

      context "when quantity_in_hand < 0.0" do
        it "is invalid" do
          stock.quantity_in_hand = -1.0
          stock.validate

          expect(stock.errors[:quantity_in_hand]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when quantity_in_hand >= 0.0" do
        it "is valid" do
          stock.quantity_in_hand = 0.00
          stock.validate

          expect(stock.errors[:quantity_in_hand]).to be_empty
        end
      end
    end

    describe "#quantity_pending_to_buyer" do
      it { is_expected.to validate_presence_of(:quantity_pending_to_buyer) }

      context "when quantity_pending_to_buyer < 0.0" do
        it "is invalid" do
          stock.quantity_pending_to_buyer = -1.0
          stock.validate

          expect(stock.errors[:quantity_pending_to_buyer]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when quantity_pending_to_buyer >= 0.0" do
        it "is valid" do
          stock.quantity_pending_to_buyer = 0.0
          stock.validate

          expect(stock.errors[:quantity_pending_to_buyer]).to be_empty
        end
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory).inverse_of(:stock).touch }
  end
end
