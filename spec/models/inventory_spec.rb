# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_spec.rb

require "spec_helper"

RSpec.describe Inventory, type: :model do
  subject(:inventory) { build(:inventory) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory) }
  end

  describe "default values" do
    let(:inventory) { described_class.new }

    it "should set average_cost as default value for #tracking_method" do
      expect(inventory.tracking_method).to eq("average_cost")
    end
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:tracking_method).backed_by_column_of_type(:enum) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "included modules" do
    it { is_expected.to include_module(HasReferenceCode) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(ActsAsMoney) }
    it { is_expected.to include_module(Navigable) }
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:low_stock_threshold) }
    it { is_expected.to apply_scale_to(:average_cost_price) }
  end

  describe "associations" do
    it { is_expected.to have_one(:stock).inverse_of(:inventory).dependent(:destroy) }
    it { is_expected.to have_one(:replenishment).inverse_of(:inventory).dependent(:destroy) }

    it { is_expected.to have_many(:inventory_movements).inverse_of(:inventory).dependent(:destroy) }
    it { is_expected.to have_many(:inventory_audit_logs).inverse_of(:inventory).dependent(:destroy) }
    it { is_expected.to have_many(:inventory_batches).inverse_of(:inventory).dependent(:destroy) }
    it { is_expected.to have_many(:stock_adjustments).inverse_of(:adjustable).dependent(:destroy) }

    it { is_expected.to belong_to(:warehouse).inverse_of(:inventories) }
    it { is_expected.to belong_to(:product).inverse_of(:inventories) }
    it { is_expected.to belong_to(:unit).inverse_of(:inventories) }
  end

  describe "validations" do
    describe "#warehouse_id" do
      it { is_expected.to validate_presence_of(:warehouse_id) }
    end

    describe "#product_id" do
      let!(:inventory) { create(:inventory) }

      it { is_expected.to validate_presence_of(:product_id) }
      it { is_expected.to validate_uniqueness_of(:product_id).scoped_to(:warehouse_id).with_message("already has inventory for the selected warehouse").ignoring_case_sensitivity }
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end

    describe "#tracking_method" do
      let(:warehouse) { build_stubbed(:warehouse) }
      let(:product) { build_stubbed(:product) }

      it { is_expected.to validate_presence_of(:tracking_method) }

      it "allows valid tracking method values" do
        described_class.tracking_methods.keys.each do |tracking_method|
          expect(build(:inventory, tracking_method:, warehouse:, product:)).to be_valid
        end
      end

      it "raises error on invalid tracking method value" do
        expect {
          build(:inventory, tracking_method: "invalid_tracking_method")
        }.to raise_error(ArgumentError, /is not a valid tracking_method/)
      end
    end

    describe "#low_stock_threshold" do
      it { is_expected.to validate_presence_of(:low_stock_threshold) }

      context "when low_stock_threshold is invalid" do
        it "is invalid" do
          inventory.low_stock_threshold = "abcd"
          inventory.validate

          expect(inventory.errors[:low_stock_threshold]).to include("must be greater than 0.0")
        end
      end

      context "when low_stock_threshold <= 0.0" do
        it "is invalid" do
          inventory.low_stock_threshold = 0.0
          inventory.validate

          expect(inventory.errors[:low_stock_threshold]).to include("must be greater than 0.0")
        end
      end

      context "when low_stock_threshold > 0.0" do
        it "is valid" do
          inventory.low_stock_threshold = 1.0
          inventory.validate

          expect(inventory.errors[:low_stock_threshold]).to be_empty
        end
      end
    end

    describe "#average_cost_price" do
      it { is_expected.to validate_presence_of(:average_cost_price) }

      context "when average_cost_price < 0.0" do
        it "is invalid" do
          inventory.average_cost_price = -0.5
          inventory.validate

          expect(inventory.errors[:average_cost_price]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when average_cost_price >= 0.0" do
        it "is valid" do
          inventory.average_cost_price = 0.0
          inventory.validate

          expect(inventory.errors[:average_cost_price]).to be_empty
        end
      end
    end
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:quantity_in_hand).to(:stock) }
    it { is_expected.to delegate_method(:quantity_pending_to_buyer).to(:stock) }
    it { is_expected.to delegate_method(:quantity_pending_from_supplier).to(:replenishment) }
    it { is_expected.to delegate_method(:symbol).to(:unit).with_prefix }
  end

  include_examples "apply default scope on created_at:desc"

  describe "instance methods" do
    describe "#key_associations" do
      let!(:inventory) { create(:inventory) }

      it "returns array of key associations" do
        expect(inventory.key_associations).to eq([inventory.product, inventory.warehouse])
      end
    end

    describe "#low_stock?" do
      let(:inventory) { create(:inventory, :with_quantity_in_hand, quantity: quantity_in_hand) }

      context "when quantity_in_hand is less than threshold" do
        let(:quantity_in_hand) { 5 }

        it "returns true" do
          expect(inventory.low_stock?).to be_truthy
        end
      end

      context "when quantity_in_hand is equal to threshold" do
        let(:quantity_in_hand) { 10 }

        it "returns true" do
          expect(inventory.low_stock?).to be_truthy
        end
      end

      context "when quantity_in_hand is greater than threshold" do
        let(:quantity_in_hand) { 20 }

        it "returns false" do
          expect(inventory.low_stock?).to be_falsy
        end
      end
    end

    describe "#product_unit_category_matches_warehouse_capacity" do
      let!(:product) { create(:product) }
      let!(:warehouse) { create(:warehouse) }

      context "when the product unit matches warehouse capacity unit category" do
        let(:inventory) { build(:inventory, warehouse:, product:) }

        it "does not add validation errors" do
          inventory.validate

          expect(inventory.errors[:product_id]).to be_blank
        end
      end

      context "when the product unit does not match warehouse capacity unit category" do
        let!(:litre_unit) { create(:litre_unit) }
        let!(:warehouse) { create(:warehouse, unit: litre_unit) }
        let(:inventory) { build(:inventory, warehouse:, product:) }

        it "adds an error on unit_id" do
          inventory.validate

          expect(inventory.errors[:product_id]).to include("is incompatible for the selected warehouse")
        end
      end

      context "when warehouse is not present" do
        let(:inventory) { build(:inventory, warehouse: nil, product:) }

        it "skips validation when warehouse is nil" do
          inventory.validate

          expect(inventory.errors[:product_id]).to be_blank
        end
      end
    end
  end
end
