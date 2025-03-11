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

    it "should set Money's default currency as default value for #currency" do
      expect(inventory.currency).to eq(Money.default_currency.iso_code)
    end
  end

  describe "included modules" do
    it { is_expected.to include_module(HasReferenceCode) }
  end

  describe "associations" do
    it { is_expected.to have_many(:inventory_movements).inverse_of(:inventory).dependent(:destroy) }
    it { is_expected.to have_many(:inventory_audit_logs).inverse_of(:inventory).dependent(:destroy) }

    it { is_expected.to belong_to(:warehouse).inverse_of(:inventories) }
    it { is_expected.to belong_to(:product).inverse_of(:inventories).touch(true) }
  end
end
