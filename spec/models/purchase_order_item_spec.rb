# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order_item_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItem, type: :model do
  let(:unit) { create(:acre_unit) }
  let(:product) { create(:product, unit:) }

  subject { create(:purchase_order_item, product:, unit:) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:purchase_order_item) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:purchase_order_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:product_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:received_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:unit_cost).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:total_cost).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:enum) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:quantity) }
    it { is_expected.to have_db_index(:product_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:purchase_order_id) }
    it { is_expected.to have_db_index(:received_quantity) }
    it { is_expected.to have_db_index([:purchase_order_id, :product_id]).unique }

    it { is_expected.to have_foreign_key(:purchase_order_id).with_name(:fk_purchase_order_items_purchase_order_id_on_purchase_orders).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:product_id).with_name(:fk_purchase_order_items_product_id_on_products).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_purchase_order_items_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_purchase_order_items_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_quantity_positive).with_expression("quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_quantity_presence).with_expression("quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_received_quantity_non_negative).with_expression("received_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_received_quantity_presence).with_expression("received_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_status_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_status_presence).with_expression("status IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_unit_cost_positive).with_expression("unit_cost > 0.0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_items_unit_cost_presence).with_expression("unit_cost IS NOT NULL") }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "included modules" do
    it { is_expected.to include_module(AASM) }
    it { is_expected.to include_module(ActsAsMoney) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum) }
  end

  describe "default values" do
    let(:purchase_order_item) { described_class.new }

    it "should set 0.0 as default value for #received_quantity" do
      expect(purchase_order_item.received_quantity).to eq(0.0)
    end

    it "should set pending as default value for #status" do
      expect(purchase_order_item.status).to eq("pending")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:purchase_order).inverse_of(:purchase_order_items) }
    it { is_expected.to belong_to(:product).inverse_of(:purchase_order_items) }
    it { is_expected.to belong_to(:unit).inverse_of(:purchase_order_items) }
  end

  describe "state machines" do
    it { is_expected.to have_state(:pending) }
    it { is_expected.to transition_from(:pending).to(:cancelled).on_event(:cancel) }
    it { is_expected.to transition_from(:pending).to(:delivered).on_event(:deliver) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :validation, :set_unit_cost_and_currency) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:symbol).to(:unit).with_prefix }
  end

  describe "validations" do
    describe "#product_id" do
      it { is_expected.to validate_presence_of(:product_id) }
      it { is_expected.to validate_uniqueness_of(:product_id).scoped_to(:purchase_order_id).with_message("has already been added").case_insensitive }
    end

    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }
      it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0.0) }
    end

    describe "#received_quantity" do
      it { is_expected.to validate_presence_of(:received_quantity) }
      it { is_expected.to validate_numericality_of(:received_quantity).is_greater_than_or_equal_to(0.0) }
    end

    describe "#unit_cost" do
      it { is_expected.to validate_presence_of(:unit_cost) }
      it { is_expected.to validate_numericality_of(:unit_cost).is_greater_than(0.0) }
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end

    describe "#status" do
      it { is_expected.to validate_presence_of(:status) }
      # it { is_expected.to validate_inclusion_of(:status).in_array(described_class.statuses.values) }
    end
  end

  describe "instance methods" do
    describe "#set_unit_cost_and_currency" do
      let!(:product) { create(:product, cost_price: 100.5, currency: "USD", unit:) }
      let!(:purchase_order) { create(:purchase_order) }

      context "when #unit_cost & #currency are not set" do
        let(:purchase_order_item) { build(:purchase_order_item, purchase_order: purchase_order, product: product) }

        it "sets unit_cost and currency from the product" do
          expect(purchase_order_item.unit_cost).to be_nil
          expect(purchase_order_item.currency.iso_code).to eq("INR")

          purchase_order_item.valid?

          expect(purchase_order_item.unit_cost).to eq(100.5)
          expect(purchase_order_item.currency.iso_code).to eq("USD")
        end
      end

      context "when #unit_cost & #currency are already set" do
        let(:purchase_order_item) { build(:purchase_order_item, purchase_order: purchase_order, product: product, unit_cost: 120.75, currency: "EUR") }

        it "overrides unit_cost and currency & sets them from the product" do
          expect(purchase_order_item.unit_cost).to eq(120.75)
          expect(purchase_order_item.currency.iso_code).to eq("EUR")

          purchase_order_item.valid?

          expect(purchase_order_item.unit_cost).to eq(100.5)
          expect(purchase_order_item.currency.iso_code).to eq("USD")
        end
      end

      context "when product is not set" do
        let(:purchase_order_item) { build(:purchase_order_item, product: nil) }

        it "does nothing" do
          expect(purchase_order_item.unit_cost).to be_nil
          expect(purchase_order_item.currency.iso_code).to eq("INR")

          purchase_order_item.valid?

          expect(purchase_order_item.unit_cost).to be_nil
          expect(purchase_order_item.currency.iso_code).to eq("INR")
        end
      end
    end
  end

  describe "instance methods" do
    describe "#unit_is_in_product_unit_category" do
      let(:product) { create(:product) }
      let(:unit) { product.unit }
      let(:invalid_unit) { build_stubbed(:kilometre_unit) }

      context "when the unit is in the valid category" do
        let!(:purchase_order_item) { build(:inventory, product:, unit:) }

        it "does not add validation errors" do
          purchase_order_item.validate

          expect(purchase_order_item.errors[:unit_id]).to be_blank
        end
      end

      context "when the unit is not in the valid category" do
        let!(:purchase_order_item) { build(:inventory, product:, unit: invalid_unit) }

        it "adds an error on unit_id" do
          purchase_order_item.validate

          expect(purchase_order_item.errors[:unit_id]).to include("is incompatible for the selected product")
        end
      end

      context "when product is not present" do
        let!(:purchase_order_item) { build(:inventory, product: nil, unit:) }

        it "does not add validation errors" do
          purchase_order_item.validate

          expect(purchase_order_item.errors[:unit_id]).to be_blank
        end
      end
    end
  end
end
