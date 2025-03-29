# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_spec.rb

require "spec_helper"

RSpec.describe Inventory, type: :model do
  subject { create(:inventory) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:batch_number).of_type(:string) }
    it { is_expected.to have_db_column(:expiration_date).of_type(:date) }
    it { is_expected.to have_db_column(:stock_quantity).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:reserved_stock).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:inventory_unit).of_type(:string) }
    it { is_expected.to have_db_column(:cost_price).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:tracking_method).of_type(:enum) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index([:product_id, :warehouse_id]).unique }
    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:warehouse_id) }

    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_inventories_product_id_on_products).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_inventories_warehouse_id_on_warehouses).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_inventories_cost_price_numericality).with_expression("cost_price >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventories_cost_price_presence).with_expression("cost_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventories_expiration_date_future).with_expression("expiration_date >= CURRENT_DATE") }
    it { is_expected.to have_check_constraint(:check_inventories_inventory_unit_presence).with_expression("inventory_unit IS NOT NULL AND inventory_unit::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventories_reserved_stock_numericality).with_expression("reserved_stock >= 0") }
    it { is_expected.to have_check_constraint(:check_inventories_reserved_stock_presence).with_expression("reserved_stock IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_stock_quantity_numericality).with_expression("stock_quantity >= 0") }
    it { is_expected.to have_check_constraint(:check_inventories_stock_quantity_presence).with_expression("stock_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_tracking_method_presence).with_expression("tracking_method IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventories_tracking_method_inclusion).with_expression("tracking_method = ANY (ARRAY['fifo'::tracking_methods, 'lifo'::tracking_methods, 'average_cost'::tracking_methods])") }
  end

  describe "default values" do
    let(:inventory) { described_class.new }

    it "should set 0 as default value for #stock_quantity" do
      expect(inventory.stock_quantity).to eq(0)
    end

    it "should set 0 as default value for #reserved_stock" do
      expect(inventory.reserved_stock).to eq(0)
    end

    it "should set 0.0 as default value for #cost_price" do
      expect(inventory.cost_price).to eq(0.0)
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
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(Navigable) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:batch_number) }
    it { is_expected.to nullify_if_blank(:expiration_date) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:batch_number) }
  end

  describe "associations" do
    it { is_expected.to have_many(:inventory_movements).inverse_of(:inventory).dependent(:destroy) }
    it { is_expected.to have_many(:inventory_audit_logs).inverse_of(:inventory).dependent(:destroy) }

    it { is_expected.to belong_to(:warehouse).inverse_of(:inventories) }
    it { is_expected.to belong_to(:product).inverse_of(:inventories).touch }
  end

  describe "validations" do
    describe "#product_id" do
      it { is_expected.to validate_presence_of(:product_id) }
      it { is_expected.to validate_uniqueness_of(:product_id).scoped_to(:warehouse_id).with_message("already has inventory for the selected warehouse").ignoring_case_sensitivity }
    end

    describe "#warehouse_id" do
      it { is_expected.to validate_presence_of(:warehouse_id) }
    end

    describe "#batch_number" do
      it { is_expected.to validate_length_of(:batch_number).is_at_most(55).allow_nil }
    end

    describe "#cost_price" do
      it { is_expected.to validate_presence_of(:cost_price) }
      it { is_expected.to validate_numericality_of(:cost_price).is_greater_than_or_equal_to(0.0) }
    end

    describe "#expiration_date" do
      it { is_expected.to validate_comparison_of(:expiration_date).is_greater_than_or_equal_to(Date.current).with_message("must be today or a future date").allow_nil }
    end

    describe "#inventory_unit" do
      it { is_expected.to validate_presence_of(:inventory_unit) }
    end

    describe "#tracking_method" do
      it { is_expected.to validate_presence_of(:tracking_method) }
      # it { is_expected.to validate_inclusion_of(:tracking_method).in_array(described_class.tracking_methods.values) }
    end
  end

  include_examples "apply default scope on created_at:desc"

  describe "instance methods" do
    describe "#inventory_unit_is_in_valid_category" do
      let(:product) { create(:product, capacity_unit: "kg") }
      let(:valid_unit) { "g" }
      let(:invalid_unit) { "l" }

      context "when inventory unit is in the valid category" do
        let!(:inventory) { build(:inventory, product: product, inventory_unit: valid_unit) }

        it "does not add validation errors" do
          inventory.validate

          expect(inventory.errors[:inventory_unit]).to be_blank
        end
      end

      context "when inventory unit is not in the valid category" do
        let!(:inventory) { build(:inventory, product: product, inventory_unit: invalid_unit) }

        it "adds an error on inventory_unit" do
          inventory.validate

          expect(inventory.errors[:inventory_unit]).to include("is not valid for the selected product")
        end
      end

      context "when product is not present" do
        let!(:inventory) { build(:inventory, product: nil, inventory_unit: valid_unit) }

        it "does not add validation errors" do
          inventory.validate

          expect(inventory.errors[:inventory_unit]).to be_blank
        end
      end
    end
  end
end
