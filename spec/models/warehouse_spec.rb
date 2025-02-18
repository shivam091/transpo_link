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
    it { is_expected.to have_db_column(:longitude).of_type(:decimal).with_options(precision: 10, scale: 8) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:reference_code).unique(true) }
    it { is_expected.to have_db_index(:is_active) }

    it { is_expected.to have_check_constraint(:check_warehouses_name_presence).with_expression("name IS NOT NULL AND name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_warehouses_total_capacity_presence).with_expression("total_capacity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_warehouses_capacity_unit_presence).with_expression("capacity_unit IS NOT NULL AND capacity_unit::text <> ''::text") }

    it { is_expected.to have_check_constraint(:check_warehouses_name_length).with_expression("char_length(name::text) <= 255 AND char_length(name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_warehouses_description_length).with_expression("char_length(description) <= 1000") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(HasReferenceCode) }
  end

  describe "default values" do
    it "should set false as default value for #is_active" do
      expect(subject.is_active).to be_falsy
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:address).inverse_of(:addressable).dependent(:destroy) }

    it { is_expected.to have_many(:warehouse_managers).inverse_of(:warehouse).dependent(:destroy) }
    it { is_expected.to have_many(:managers).through(:warehouse_managers).inverse_of(:managed_warehouses).source(:manager) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :create, :set_reference_code) }
  end
end
