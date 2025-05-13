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

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:tracking_method).of_type(:enum) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:average_cost_price).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:low_stock_threshold).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:warehouse_id) }
    it { is_expected.to have_db_index([:product_id, :warehouse_id]).unique }

    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_inventories_product_id_on_products).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_inventories_warehouse_id_on_warehouses).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_inventories_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_inventories_average_cost_price_non_negative).with_expression("average_cost_price >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventories_average_cost_price_presence).with_expression("average_cost_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventories_low_stock_threshold_positive).with_expression("low_stock_threshold > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventories_low_stock_threshold_presence).with_expression("low_stock_threshold IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_tracking_method_presence).with_expression("tracking_method IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_tracking_method_in_enum_values).with_expression("tracking_method = ANY (ARRAY['fifo'::tracking_methods, 'lifo'::tracking_methods, 'average_cost'::tracking_methods])") }
  end

  describe "default values" do
    let(:inventory) { described_class.new }

    it "should set 0.0 as default value for #average_cost_price" do
      expect(inventory.average_cost_price).to eq(0.0)
    end

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
      it { is_expected.to validate_presence_of(:tracking_method) }
      # it { is_expected.to validate_inclusion_of(:tracking_method).in_array(described_class.tracking_methods.values) }
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
