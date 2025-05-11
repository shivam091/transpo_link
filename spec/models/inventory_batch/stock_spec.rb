# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_batch/stock_spec.rb

require "spec_helper"

RSpec.describe InventoryBatch::Stock, type: :model do
  subject(:inventory_batch_stock) { build(:inventory_batch_stock) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_batch_stock) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:inventory_batch_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:ordered_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:reserved_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:damaged_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:returned_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:restocked_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:restockable_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:available_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:used_quantity).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:status).of_type(:enum) }
    it { is_expected.to have_db_column(:is_locked).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:inventory_batch_id).unique }
    it { is_expected.to have_db_index(:is_locked) }
    it { is_expected.to have_db_index(:status) }
    it { is_expected.to have_db_index([:status, :is_locked]) }

    it { is_expected.to have_foreign_key(:inventory_batch_id).with_name(:fk_inventory_batch_stocks_inventory_batch_id_on_inventory_batch).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_ordered_quantity_presence).with_expression("ordered_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_ordered_quantity_non_negative).with_expression("ordered_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_reserved_quantity_presence).with_expression("reserved_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_reserved_quantity_non_negative).with_expression("reserved_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_damaged_quantity_presence).with_expression("damaged_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_damaged_quantity_non_negative).with_expression("damaged_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_returned_quantity_presence).with_expression("returned_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_returned_quantity_non_negative).with_expression("returned_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_restocked_quantity_presence).with_expression("restocked_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_restocked_quantity_non_negative).with_expression("restocked_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_restockable_quantity_presence).with_expression("restockable_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_restockable_quantity_non_negative).with_expression("restockable_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_available_quantity_presence).with_expression("available_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_available_quantity_non_negative).with_expression("available_quantity >= 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_status_presence).with_expression("status IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batch_stocks_status_in_enum_values) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum) }
  end

  describe "included modules" do
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:ordered_quantity) }
    it { is_expected.to apply_scale_to(:reserved_quantity) }
    it { is_expected.to apply_scale_to(:damaged_quantity) }
    it { is_expected.to apply_scale_to(:returned_quantity) }
    it { is_expected.to apply_scale_to(:restocked_quantity) }
    it { is_expected.to apply_scale_to(:restockable_quantity) }
    it { is_expected.to apply_scale_to(:available_quantity) }
    it { is_expected.to apply_scale_to(:used_quantity) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory_batch).inverse_of(:stock) }
  end
end
