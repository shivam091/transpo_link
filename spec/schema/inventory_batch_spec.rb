# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/inventory_batch_spec.rb

require "spec_helper"

RSpec.describe InventoryBatch, type: :model do
  subject(:inventory_batch) { build(:inventory_batch) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:batch_number).of_type(:string) }
    it { is_expected.to have_db_column(:lot_number).of_type(:string) }
    it { is_expected.to have_db_column(:manufactured_at).of_type(:date) }
    it { is_expected.to have_db_column(:expiration_date).of_type(:date) }
    it { is_expected.to have_db_column(:received_at).of_type(:date) }
    it { is_expected.to have_db_column(:location).of_type(:string) }
    it { is_expected.to have_db_column(:notes).of_type(:text) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:cost_price).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:source_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:source_type).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:inventory_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:expiration_date) }
    it { is_expected.to have_db_index([:source_type, :source_id]) }
    it { is_expected.to have_db_index("inventory_id, batch_number, COALESCE(lot_number, ''::character varying)").unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_inventory_batches_inventory_id_on_inventories).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_inventory_batches_unit_id_on_units).on_delete(:restrict) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_inventory_batches_batch_number_presence).with_expression("batch_number IS NOT NULL AND batch_number::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_batch_number_length).with_expression("char_length(batch_number::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_cost_price_positive).with_expression("cost_price > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_cost_price_presence).with_expression("cost_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_expiration_future).with_expression("expiration_date IS NULL OR expiration_date >= CURRENT_DATE") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_quantity_positive).with_expression("quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_quantity_presence).with_expression("quantity IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_location_length).with_expression("char_length(location::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_location_presence).with_expression("location IS NOT NULL AND location::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_lot_number_length).with_expression("lot_number IS NULL OR char_length(lot_number::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_received_at_presence).with_expression("lot_number IS NULL OR received_at IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_manufactured_before_expiry).with_expression("manufactured_at IS NULL OR expiration_date IS NULL OR manufactured_at <= expiration_date") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_notes_length).with_expression("notes IS NULL OR char_length(notes) <= 1000") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_received_after_manufactured).with_expression("received_at IS NULL OR manufactured_at IS NULL OR manufactured_at <= received_at") }
  end
end
