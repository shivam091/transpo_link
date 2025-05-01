# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_batch_spec.rb

require "spec_helper"

RSpec.describe InventoryBatch, type: :model do
  subject(:inventory_batch) { build(:inventory_batch) }

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
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:expiration_date) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:batch_number) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:quantity) }
    it { is_expected.to apply_scale_to(:cost_price) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :create, :convert_to_inventory_unit) }
    it { is_expected.to have_callback(:after, :save, :update_inventory_average_cost_price) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:symbol).to(:unit).with_prefix }
  end

  describe "validations" do
    describe "#batch_number" do
      let!(:inventory_batch) { create(:inventory_batch, batch_number: "ABC123") }

      it { is_expected.to validate_presence_of(:batch_number) }
      it { is_expected.to validate_length_of(:batch_number).is_at_most(55) }
      it { is_expected.to validate_uniqueness_of(:batch_number).scoped_to(:inventory_id).with_message("already exists for the selected inventory") }
    end

    describe "#expiration_date" do
      it { is_expected.to validate_comparison_of(:expiration_date).is_greater_than_or_equal_to(Date.current).with_message("must be today or a future date").allow_nil }
    end

    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }

      context "when quantity is invalid" do
        it "is invalid" do
          inventory_batch.quantity = "abcd"
          inventory_batch.validate

          expect(inventory_batch.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity <= 0.0" do
        it "is invalid" do
          inventory_batch.quantity = 0.0
          inventory_batch.validate

          expect(inventory_batch.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity > 0.0" do
        it "is valid" do
          inventory_batch.quantity = 1.0
          inventory_batch.validate

          expect(inventory_batch.errors[:quantity]).to be_empty
        end
      end
    end

    describe "#cost_price" do
      it { is_expected.to validate_presence_of(:cost_price) }

      context "when cost_price is invalid" do
        it "is invalid" do
          inventory_batch.cost_price = "abcd"
          inventory_batch.validate

          expect(inventory_batch.errors[:cost_price]).to include("must be greater than 0.0")
        end
      end

      context "when cost_price <= 0.0" do
        it "is invalid" do
          inventory_batch.cost_price = 0.0
          inventory_batch.validate

          expect(inventory_batch.errors[:cost_price]).to include("must be greater than 0.0")
        end
      end

      context "when cost_price > 0.0" do
        it "is valid" do
          inventory_batch.cost_price = 1.0
          inventory_batch.validate

          expect(inventory_batch.errors[:cost_price]).to be_empty
        end
      end
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:inventory_batch_audit_logs).inverse_of(:inventory_batch).dependent(:nullify) }
    it { is_expected.to have_many(:inventory_batch_processing_logs).inverse_of(:inventory_batch).dependent(:nullify) }

    it { is_expected.to belong_to(:inventory).inverse_of(:inventory_batches).touch }
    it { is_expected.to belong_to(:unit).inverse_of(:inventory_batches) }
  end

  describe "scopes" do
    describe ".by_batch_number_and_expiry" do
      let(:inventory) { create(:inventory) }

      let!(:batch_with_expiry) { create(:inventory_batch, inventory:, batch_number: "B001", expiration_date: 1.year.from_now) }
      let!(:batch_without_expiry) { create(:inventory_batch, inventory:, batch_number: "B002", expiration_date: nil) }

      it "finds batch with matching batch_number and expiration_date" do
        batch = described_class.by_batch_number_and_expiry("B001", 1.year.from_now).first

        expect(batch).to eq(batch_with_expiry)
      end

      it "finds batch with nil expiration_date" do
        batch = described_class.by_batch_number_and_expiry("B002", nil).first

        expect(batch).to eq(batch_without_expiry)
      end

      it "returns nil if no batch matches the batch_number and expiration_date" do
        batch = described_class.by_batch_number_and_expiry("B001", Date.tomorrow).first

        expect(batch).to be_nil
      end
    end
  end

  describe "instance methods" do
    describe "#update_inventory_average_cost_price" do
      let(:inventory) { create(:inventory) }
      let(:inventory_batch) { build(:inventory_batch, inventory:) }

      it "calls Inventories::UpdateAverageCostPriceService with the inventory" do
        expect(Inventories::UpdateAverageCostPriceService).to receive(:call).with(inventory)

        inventory_batch.save! # triggers after_save callback
      end
    end

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

    describe "#previous_quantity" do
      let(:inventory_batch) { create(:inventory_batch, quantity: 10.0) }

      context "when quantity has been updated" do
        before { inventory_batch.update(quantity: 15.0) }

        it "returns the previous quantity value" do
          expect(inventory_batch.previous_quantity).to eq(10.0)
        end
      end

      context "when quantity has not changed" do
        it "returns 0.0" do
          expect(inventory_batch.previous_quantity).to eq(0.0)
        end
      end

      context "when quantity_previously_was is nil" do
        let(:new_batch) { build(:inventory_batch, quantity: 5.0) }

        it "returns 0.0 for new records" do
          expect(new_batch.previous_quantity).to eq(0.0)
        end
      end
    end

    describe "#quantity_change" do
      let!(:inventory_batch) { create(:inventory_batch, quantity: 10) }

      context "when quantity has changed" do
        it "returns the change in quantity" do
          inventory_batch.update(quantity: 15)

          expect(inventory_batch.quantity_change).to eq(5)
        end
      end

      context "when quantity has not changed" do
        it "returns original quantity" do
          expect(inventory_batch.quantity_change).to eq(10)
        end
      end
    end

    describe "merge_with!" do
      let(:unit) { create(:item_unit) }
      let(:inventory) { create(:inventory, unit:) }
      let(:inventory_batch) { create(:inventory_batch, inventory:, unit:, quantity: 10) }

      context "when source_unit is not provided" do
        it "adds quantity directly and saves the batch" do
          expect {
            inventory_batch.merge_with!(quantity: 5)
          }.to change { inventory_batch.reload.quantity }.by(5)
        end
      end

      context "when source_unit is different from batch unit" do
        let(:source_unit) { create(:dozen_unit) }

        it "converts quantity before adding and saves the batch" do
          expect(UnitConversion).to receive(:convert).with(source_unit, unit, 2) { 24 }

          expect {
            inventory_batch.merge_with!(quantity: 2, source_unit:)
          }.to change { inventory_batch.reload.quantity }.by(24)
        end
      end

      context "when source_unit is same as batch unit" do
        it "adds quantity without conversion and saves the batch" do
          expect(UnitConversion).not_to receive(:convert)

          expect {
            inventory_batch.merge_with!(quantity: 3, source_unit: unit)
          }.to change { inventory_batch.reload.quantity }.by(3)
        end
      end

      context "when quantity is missing" do
        it "raises ArgumentError" do
          expect {
            inventory_batch.merge_with!({})
          }.to raise_error(ArgumentError, "Quantity must be present")
        end
      end
    end
  end
end
