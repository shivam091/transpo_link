# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_batch_spec.rb

require "spec_helper"

RSpec.describe InventoryBatch, type: :model do
  subject { create(:inventory_batch) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_batch) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:batch_number).of_type(:string) }
    it { is_expected.to have_db_column(:expiration_date).of_type(:date) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:cost_price).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:currency).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:inventory_id) }
    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index([:inventory_id, :batch_number]).unique }

    it { is_expected.to have_foreign_key(:inventory_id).with_name(:fk_inventory_batches_inventory_id_on_inventories).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_inventory_batches_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_inventory_batches_batch_number_presence).with_expression("batch_number IS NOT NULL AND batch_number::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_batch_number_length).with_expression("char_length(batch_number::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_cost_price_positive).with_expression("cost_price > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_cost_price_presence).with_expression("cost_price IS NOT NULL") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_currency_presence).with_expression("currency IS NOT NULL AND currency::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_expiration_date_future).with_expression("expiration_date >= CURRENT_DATE") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_quantity_positive).with_expression("quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_batches_quantity_presence).with_expression("quantity IS NOT NULL") }
  end

  describe "included modules" do
    it { is_expected.to include_module(ActsAsMoney) }
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:expiration_date) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:batch_number) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :create, :convert_to_inventory_unit) }
    it { is_expected.to have_callback(:after, :save, :update_inventory_average_cost_price) }
  end

  describe "validations" do
    describe "#batch_number" do
      it { is_expected.to validate_presence_of(:batch_number) }
      it { is_expected.to validate_length_of(:batch_number).is_at_most(55) }
      it { is_expected.to validate_uniqueness_of(:batch_number).scoped_to(:inventory_id).with_message("already exists for the selected inventory") }
    end

    describe "#expiration_date" do
      it { is_expected.to validate_comparison_of(:expiration_date).is_greater_than_or_equal_to(Date.current).with_message("must be today or a future date").allow_nil }
    end

    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }
      it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0.0) }
    end

    describe "#cost_price" do
      it { is_expected.to validate_presence_of(:cost_price) }
      it { is_expected.to validate_numericality_of(:cost_price).is_greater_than(0.0) }
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory).inverse_of(:inventory_batches).touch }
    it { is_expected.to belong_to(:unit).inverse_of(:inventory_batches) }
  end

  describe "instance methods" do
    describe "#convert_to_inventory_unit" do
      let!(:target_unit) { create(:dozen_unit) }
      let!(:source_unit) { create(:item_unit) }

      let(:inventory) { create(:inventory, unit: target_unit) }

      context "when source and target units are the same" do
        let(:inventory_batch) { build(:inventory_batch, inventory:, unit: target_unit, quantity: 10) }

        it "does not change quantity or unit" do
          expect(UnitConversion).not_to receive(:convert)
          inventory_batch.save!

          expect(inventory_batch.quantity).to eq(10)
          expect(inventory_batch.unit).to eq(target_unit)
        end
      end

      context "when source and target units are different and conversion succeeds" do
        let(:inventory_batch) { build(:inventory_batch, inventory:, unit: source_unit, quantity: 5) }

        it "converts the quantity and sets unit to target unit" do
          allow(UnitConversion).to receive(:convert).with(source_unit, target_unit, 5) { 10 }

          inventory_batch.save!

          expect(inventory_batch.quantity).to eq(10)
          expect(inventory_batch.unit).to eq(target_unit)
        end
      end
    end
  end
end
