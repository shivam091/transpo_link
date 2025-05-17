# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/warehouse_spec.rb

require "spec_helper"

RSpec.describe Warehouse, type: :model do
  subject(:warehouse) { build(:warehouse) }

  describe "attributes" do
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
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:reference_code).unique }
    it { is_expected.to have_db_index(:email_address).unique }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:is_active) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_warehouses_unit_id_on_units).on_delete(:restrict) }
  end

  describe "check constraints" do
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
end
