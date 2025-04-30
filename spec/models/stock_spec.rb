# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/stock_spec.rb

require "spec_helper"

RSpec.describe Stock, type: :model do
  subject { build(:stock) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:stock) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:quantity_in_hand).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:quantity_pending_to_buyer).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0)}
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:inventory_id).unique }

    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_stocks_inventory_id_on_inventories).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_stocks_quantity_in_hand_non_negative).with_expression("quantity_in_hand >= 0.0") }
    it { is_expected.to have_check_constraint(:check_stocks_quantity_in_hand_presence).with_expression("quantity_in_hand IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_stocks_quantity_pending_to_buyer_non_negative).with_expression("quantity_pending_to_buyer >= 0.0") }
    it { is_expected.to have_check_constraint(:check_stocks_quantity_pending_to_buyer_presence).with_expression("quantity_pending_to_buyer IS NOT NULL") }
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
          subject.quantity_in_hand = -1.0
          subject.validate

          expect(subject.errors[:quantity_in_hand]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when quantity_in_hand >= 0.0" do
        it "is valid" do
          subject.quantity_in_hand = 0.00
          subject.validate

          expect(subject.errors[:quantity_in_hand]).to be_empty
        end
      end
    end

    describe "#quantity_pending_to_buyer" do
      it { is_expected.to validate_presence_of(:quantity_pending_to_buyer) }

      context "when quantity_pending_to_buyer < 0.0" do
        it "is invalid" do
          subject.quantity_pending_to_buyer = -1.0
          subject.validate

          expect(subject.errors[:quantity_pending_to_buyer]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when quantity_pending_to_buyer >= 0.0" do
        it "is valid" do
          subject.quantity_pending_to_buyer = 0.0
          subject.validate

          expect(subject.errors[:quantity_pending_to_buyer]).to be_empty
        end
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory).inverse_of(:stock).touch }
  end
end
