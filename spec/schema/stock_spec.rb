# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/stock_spec.rb

require "spec_helper"

RSpec.describe Stock, type: :model do
  subject(:stock) { build(:stock) }

  describe "attributes" do
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:quantity_in_hand).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0) }
    it { is_expected.to have_db_column(:quantity_pending_to_buyer).of_type(:decimal).with_options(precision: 12, scale: 2, default: 0.0)}
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:inventory_id).unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_stocks_inventory_id_on_inventories).on_delete(:cascade) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_stocks_quantity_in_hand_non_negative).with_expression("quantity_in_hand >= 0.0") }
    it { is_expected.to have_check_constraint(:check_stocks_quantity_in_hand_presence).with_expression("quantity_in_hand IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_stocks_quantity_pending_to_buyer_non_negative).with_expression("quantity_pending_to_buyer >= 0.0") }
    it { is_expected.to have_check_constraint(:check_stocks_quantity_pending_to_buyer_presence).with_expression("quantity_pending_to_buyer IS NOT NULL") }
  end
end
