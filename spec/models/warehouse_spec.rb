# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/warehouse_spec.rb

require "spec_helper"

RSpec.describe Warehouse, type: :model do
  subject(:warehouse) { build(:warehouse) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:warehouse) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:reference_code).of_type(:string) }
    it { is_expected.to have_db_column(:email_address).of_type(:string) }
    it { is_expected.to have_db_column(:contact_number).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:total_capacity).of_type(:decimal).with_options(precision: 15, scale: 4) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:latitude).of_type(:decimal).with_options(precision: 15, scale: 13) }
    it { is_expected.to have_db_column(:longitude).of_type(:decimal).with_options(precision: 15, scale: 12) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:email_address).unique }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:is_active) }

    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_warehouses_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_warehouses_name_presence).with_expression("name IS NOT NULL AND name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_warehouses_total_capacity_presence).with_expression("total_capacity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_warehouses_name_length).with_expression("char_length(name::text) <= 255 AND char_length(name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_warehouses_description_length).with_expression("char_length(description) <= 1000") }
    it { is_expected.to have_check_constraint(:check_warehouses_email_address_length).with_expression("char_length(email_address::text) <= 55 AND char_length(email_address::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_warehouses_contact_number_length).with_expression("char_length(contact_number::text) <= 55 AND char_length(contact_number::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_warehouses_total_capacity_range).with_expression("total_capacity > 0.0 AND total_capacity < 100000000000.0") }
    it { is_expected.to have_check_constraint(:check_warehouses_latitude_range).with_expression("latitude >= '-90.0'::numeric AND latitude <= 90.0") }
    it { is_expected.to have_check_constraint(:check_warehouses_longitude_range).with_expression("longitude >= '-180.0'::numeric AND longitude <= 180.0") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(HasReferenceCode) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(Navigable) }
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:email_address) }
    it { is_expected.to nullify_if_blank(:contact_number) }
    it { is_expected.to nullify_if_blank(:description) }
    it { is_expected.to nullify_if_blank(:latitude) }
    it { is_expected.to nullify_if_blank(:longitude) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:name) }
    it { is_expected.to sanitize_attribute(:email_address) }
    it { is_expected.to sanitize_attribute(:contact_number) }
    it { is_expected.to sanitize_attribute(:description) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:total_capacity) }
    it { is_expected.to apply_scale_to(:latitude) }
    it { is_expected.to apply_scale_to(:longitude) }
  end

  describe "associations" do
    it { is_expected.to have_one(:address).inverse_of(:addressable).dependent(:destroy) }

    it { is_expected.to have_many(:warehouse_managers).class_name("Warehouse::Manager").inverse_of(:warehouse).dependent(:destroy) }
    it { is_expected.to have_many(:managers).through(:warehouse_managers).inverse_of(:managed_warehouses).source(:manager) }

    it { is_expected.to have_many(:warehouse_suppliers).class_name("Warehouse::Supplier").inverse_of(:warehouse).dependent(:destroy) }
    it { is_expected.to have_many(:suppliers).through(:warehouse_suppliers).inverse_of(:supplied_warehouses).source(:supplier) }

    it { is_expected.to have_many(:purchase_order_items).through(:purchase_orders).inverse_of(:warehouse).dependent(:restrict_with_exception) }

    it { is_expected.to have_many(:inventories).inverse_of(:warehouse).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:products).through(:inventories).inverse_of(:warehouses) }

    it { is_expected.to have_many(:product_prices).inverse_of(:warehouse).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:purchase_orders).inverse_of(:warehouse).dependent(:restrict_with_exception) }

    it { is_expected.to belong_to(:unit).inverse_of(:warehouses) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:symbol).to(:unit).with_prefix }
    it { is_expected.to delegate_method(:category).to(:unit).with_prefix }
  end

  include_examples "apply default scope on created_at:desc"

  describe "validations" do
    describe "#name" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(255) }
    end

    describe "#email_address" do
      it { is_expected.to validate_length_of(:email_address).is_at_least(2).is_at_most(55).allow_blank }
      it { is_expected.to validate_uniqueness_of(:email_address) }
    end

    describe "#contact_number" do
      it { is_expected.to validate_length_of(:contact_number).is_at_least(2).is_at_most(55).allow_blank }
    end

    describe "#description" do
      it { is_expected.to validate_length_of(:description).is_at_most(1000).allow_blank }
    end

    describe "#total_capacity" do
      it { is_expected.to validate_presence_of(:total_capacity) }

      context "when total_capacity <= 0.0" do
        it "is invalid" do
          warehouse.total_capacity = 0.0
          warehouse.validate

          expect(warehouse.errors[:total_capacity]).to include("must be greater than 0.0")
        end
      end

      context "when total_capacity >= 100000000000.0" do
        it "is invalid" do
          warehouse.total_capacity = 100000000001.0
          warehouse.validate

          expect(warehouse.errors[:total_capacity]).to include("must be less than 100000000000.0")
        end
      end

      context "when total_capacity < 100000000000.0 and total_capacity > 0.0" do
        it "is valid" do
          warehouse.total_capacity = 10000.0
          warehouse.validate

          expect(warehouse.errors[:total_capacity]).to be_empty
        end
      end
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end

    describe "#latitude" do
      context "when latitude < -90.0" do
        it "is invalid" do
          warehouse.latitude = -91.0
          warehouse.validate

          expect(warehouse.errors[:latitude]).to include("must be greater than or equal to -90.0")
        end
      end

      context "when latitude > 90.0" do
        it "is invalid" do
          warehouse.latitude = 91.0
          warehouse.validate

          expect(warehouse.errors[:latitude]).to include("must be less than or equal to 90.0")
        end
      end

      context "when latitude is between -90.0 and 90.0" do
        it "is valid" do
          warehouse.latitude = 25
          warehouse.validate

          expect(warehouse.errors[:latitude]).to be_empty
        end
      end

      context "when latitude is empty or nil" do
        it "is valid" do
          warehouse.latitude = nil
          warehouse.validate

          expect(warehouse.errors[:latitude]).to be_empty
        end
      end
    end

    describe "#longitude" do
      context "when longitude < -180.0" do
        it "is invalid" do
          warehouse.longitude = -181.0
          warehouse.validate

          expect(warehouse.errors[:longitude]).to include("must be greater than or equal to -180.0")
        end
      end

      context "when longitude > 180.0" do
        it "is invalid" do
          warehouse.longitude = 181.0
          warehouse.validate

          expect(warehouse.errors[:longitude]).to include("must be less than or equal to 180.0")
        end
      end

      context "when longitude is between -180.0 and 180.0" do
        it "is valid" do
          warehouse.longitude = 25
          warehouse.validate

          expect(warehouse.errors[:longitude]).to be_empty
        end
      end

      context "when longitude is empty or nil" do
        it "is valid" do
          warehouse.longitude = nil
          warehouse.validate

          expect(warehouse.errors[:longitude]).to be_empty
        end
      end
    end
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:address).update_only(true) }
  end

  describe "class methods" do
    describe ".select_options" do
      let!(:warehouse) { create(:warehouse, :active) }

      it "should return array of warehouses for select list" do
        expect(described_class.select_options).to eq([[warehouse.name, warehouse.id]])
      end
    end
  end
end
