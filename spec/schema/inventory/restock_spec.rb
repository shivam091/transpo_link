# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/inventory/restock_spec.rb

require "spec_helper"

RSpec.describe Inventory::Restock, type: :model do
  subject(:inventory_restock) { build(:inventory_restock) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_batch_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:comment).of_type(:text) }
    it { is_expected.to have_db_column(:note).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:inventory_batch_id) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_inventory_restocks_unit_id_on_units).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:inventory_batch_id).with_name(:fk_inventory_restocks_inventory_batch_id_on_inventory_batches).on_delete(:cascade) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_inventory_restocks_comment_length).with_expression("char_length(comment) <= 1000 AND char_length(comment) > 0") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_note_length).with_expression("char_length(note) <= 1000") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_comment_presence).with_expression("comment IS NOT NULL AND comment <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_quantity_positive).with_expression("quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_quantity_presence).with_expression("quantity IS NOT NULL") }
  end
end
