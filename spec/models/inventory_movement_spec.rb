# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_movement_spec.rb

require "spec_helper"

RSpec.describe InventoryMovement, type: :model do
  subject { create(:inventory_movement) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_movement) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:movement_type).of_type(:enum) }
    it { is_expected.to have_db_column(:inventory_unit).of_type(:string) }
    it { is_expected.to have_db_column(:unit_cost).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:total_cost).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:movement_date).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:source_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:source_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:metadata).of_type(:jsonb).with_options(default: "{}") }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index([:inventory_id, :source_id, :source_type, :movement_type]) }
    it { is_expected.to have_db_index(:inventory_id) }
    it { is_expected.to have_db_index(:metadata) }
    it { is_expected.to have_db_index([:source_type, :source_id]) }

    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_inventory_movements_inventory_id_on_inventories).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_inventory_movements_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_inventory_unit_presence).with_expression("inventory_unit IS NOT NULL AND inventory_unit::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_movement_type_inclusion) }
    it { is_expected.to have_check_constraint(:check_inventory_movements_movement_type_presence).with_expression("movement_type IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_quantity_nonzero).with_expression("quantity <> 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_quantity_presence).with_expression("quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_total_cost_numericality).with_expression("total_cost >= unit_cost") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_total_cost_presence).with_expression("total_cost IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_unit_cost_numericality).with_expression("unit_cost >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_movements_unit_cost_presence).with_expression("unit_cost IS NOT NULL") }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:movement_type).backed_by_column_of_type(:enum) }
  end

  describe "associations" do
    it { is_expected.to have_many(:inventory_audit_logs).inverse_of(:inventory_movement).dependent(:destroy) }

    it { is_expected.to belong_to(:inventory).inverse_of(:inventory_movements) }
    it { is_expected.to belong_to(:source).optional }
  end
end
