# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/warehouse_manager_spec.rb

require "spec_helper"

RSpec.describe WarehouseManager, type: :model do
  subject { create(:warehouse_manager) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:warehouse_manager) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:manager_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:warehouse_id) }
    it { is_expected.to have_db_index(:manager_id) }

    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_warehouse_managers_warehouse_id_on_warehouses).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:manager_id).with_name(:fk_warehouse_managers_manager_id_on_users).on_delete(:restrict) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:warehouse).inverse_of(:warehouse_managers).touch }
    it { is_expected.to belong_to(:manager).inverse_of(:warehouse_managers).class_name("User") }
  end

  describe "validations" do
    describe "#warehouse_id" do
      it { is_expected.to validate_presence_of(:warehouse_id) }
    end

    describe "#manager_id" do
      it { is_expected.to validate_presence_of(:manager_id) }
    end
  end
end
