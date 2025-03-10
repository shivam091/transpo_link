# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/warehouse_spec.rb

require "spec_helper"

RSpec.describe Warehouse, type: :model do
  subject { create(:warehouse) }

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
    it { is_expected.to have_db_column(:total_capacity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:capacity_unit).of_type(:string) }
    it { is_expected.to have_db_column(:latitude).of_type(:decimal).with_options(precision: 10, scale: 8) }
    it { is_expected.to have_db_column(:longitude).of_type(:decimal).with_options(precision: 11, scale: 8) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:reference_code).unique(true) }
    it { is_expected.to have_db_index(:email_address).unique(true) }
    it { is_expected.to have_db_index(:is_active) }

    it { is_expected.to have_check_constraint(:check_warehouses_name_presence).with_expression("name IS NOT NULL AND name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_warehouses_total_capacity_presence).with_expression("total_capacity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_warehouses_capacity_unit_presence).with_expression("capacity_unit IS NOT NULL AND capacity_unit::text <> ''::text") }

    it { is_expected.to have_check_constraint(:check_warehouses_name_length).with_expression("char_length(name::text) <= 255 AND char_length(name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_warehouses_description_length).with_expression("char_length(description) <= 1000") }
    it { is_expected.to have_check_constraint(:check_warehouses_email_address_length).with_expression("char_length(email_address::text) <= 55 AND char_length(email_address::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_warehouses_contact_number_length).with_expression("char_length(contact_number::text) <= 55 AND char_length(contact_number::text) >= 2") }

    it { is_expected.to have_check_constraint(:check_warehouses_total_capacity_range).with_expression("total_capacity >= 0::numeric AND total_capacity <= '100000000000'::bigint::numeric") }
    it { is_expected.to have_check_constraint(:check_warehouses_latitude_range).with_expression("latitude >= '-90'::integer::numeric AND latitude <= 90::numeric") }
    it { is_expected.to have_check_constraint(:check_warehouses_longitude_range).with_expression("longitude >= '-180'::integer::numeric AND longitude <= 180::numeric") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(HasReferenceCode) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sortable) }
  end

  describe "default values" do
    it "should set false as default value for #is_active" do
      expect(subject.is_active).to be_falsy
    end
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "associations" do
    it { is_expected.to have_one(:address).inverse_of(:addressable).dependent(:destroy) }

    it { is_expected.to have_many(:warehouse_managers).inverse_of(:warehouse).dependent(:destroy) }
    it { is_expected.to have_many(:managers).through(:warehouse_managers).inverse_of(:managed_warehouses).source(:manager) }

    it { is_expected.to have_many(:warehouse_suppliers).inverse_of(:warehouse).dependent(:destroy) }
    it { is_expected.to have_many(:suppliers).through(:warehouse_suppliers).inverse_of(:supplied_warehouses).source(:supplier) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:after, :initialize, :set_reference_code) }
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
      it { is_expected.to validate_numericality_of(:total_capacity).is_greater_than(0).is_less_than(10**10) }
    end

    describe "#capacity_unit" do
      it { is_expected.to validate_presence_of(:capacity_unit) }
      it { is_expected.to validate_inclusion_of(:capacity_unit).in_array(TranspoLink::MeasurementUnits.all_units.map(&:to_s)) }
    end

    describe "#latitude" do
      it { is_expected.to validate_numericality_of(:latitude).is_greater_than_or_equal_to(-90).is_less_than_or_equal_to(90).allow_nil }
    end

    describe "#longitude" do
      it { is_expected.to validate_numericality_of(:longitude).is_greater_than_or_equal_to(-180).is_less_than_or_equal_to(180).allow_nil }
    end

    describe "#manager_ids" do
      it { is_expected.to validate_presence_of(:manager_ids) }
    end

    describe "#supplier_ids" do
      it { is_expected.to validate_presence_of(:supplier_ids) }
    end
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:address).update_only(true) }
  end
end
