# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/stock_adjustment_spec.rb

require "spec_helper"

RSpec.describe StockAdjustment, type: :model do
  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_batch_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:source_type).of_type(:string).with_options(null: true) }
    it { is_expected.to have_db_column(:source_id).of_type(:uuid).with_options(null: true) }
    it { is_expected.to have_db_column(:user_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:adjusted_quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:adjustment_reason).of_type(:enum) }
    it { is_expected.to have_db_column(:note).of_type(:text) }
    it { is_expected.to have_db_column(:adjusted_at).of_type(:timestamptz) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index([:source_type, :source_id]) }
    it { is_expected.to have_db_index(:adjusted_at) }
    it { is_expected.to have_db_index(:inventory_batch_id) }
    it { is_expected.to have_db_index(:adjustment_reason) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:user_id) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:inventory_batch_id).with_name(:fk_stock_adjustments_inventory_batch_id_on_inventory_batches).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_stock_adjustments_unit_id_on_units).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:user_id).with_name(:fk_stock_adjustments_user_id_on_user).on_delete(:nullify) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_stock_adjustments_adjusted_at_not_in_future).with_expression("adjusted_at <= CURRENT_TIMESTAMP") }
    it { is_expected.to have_check_constraint(:check_stock_adjustments_adjusted_at_presence).with_expression("adjusted_at IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_stock_adjustments_adjusted_quantity_positive).with_expression("adjusted_quantity > 0::numeric") }
    it { is_expected.to have_check_constraint(:check_stock_adjustments_adjusted_quantity_presence).with_expression("adjusted_quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_stock_adjustments_note_length).with_expression("note IS NULL OR char_length(note) <= 1000") }
    it { is_expected.to have_check_constraint(:check_stock_adjustments_adjustment_reason_in_enum_values) }
    it { is_expected.to have_check_constraint(:check_stock_adjustments_adjustment_reason_presence).with_expression("adjustment_reason IS NOT NULL") }
  end
end
