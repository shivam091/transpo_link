# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory_batch_spec.rb

require "spec_helper"

RSpec.describe InventoryBatch, type: :model do
  subject(:inventory_batch) { build(:inventory_batch) }

  include_context "with current user"

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_batch) }
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
    it { is_expected.to nullify_if_blank(:lot_number) }
    it { is_expected.to nullify_if_blank(:notes) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:batch_number) }
    it { is_expected.to sanitize_attribute(:lot_number) }
    it { is_expected.to sanitize_attribute(:location) }
    it { is_expected.to sanitize_attribute(:notes) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:quantity) }
    it { is_expected.to apply_scale_to(:cost_price) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :validation, :auto_fill_cost_and_currency) }
    it { is_expected.to have_callback(:before, :create, :convert_to_inventory_unit) }
    it { is_expected.to have_callback(:after, :save, :record_audit_logs) }
    it { is_expected.to have_callback(:after, :save, :update_inventory_average_cost_price) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:symbol).to(:unit).with_prefix }
    it { is_expected.to delegate_method(:category).to(:unit).with_prefix }
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:restocks).allow_destroy(false) }
  end

  describe "associations" do
    it { is_expected.to have_one(:product) }
    it { is_expected.to have_one(:warehouse) }
    it { is_expected.to have_one(:stock).class_name("InventoryBatch::Stock").inverse_of(:inventory_batch).dependent(:destroy) }

    it { is_expected.to have_many(:inventory_batch_audit_logs).inverse_of(:inventory_batch).dependent(:nullify) }
    it { is_expected.to have_many(:restocks).class_name("Inventory::Restock").inverse_of(:inventory_batch).dependent(:destroy) }
    it { is_expected.to have_many(:stock_adjustments).inverse_of(:inventory_batch).dependent(:destroy) }

    it { is_expected.to belong_to(:inventory).inverse_of(:inventory_batches).touch }
    it { is_expected.to belong_to(:unit).inverse_of(:inventory_batches) }
    it { is_expected.to belong_to(:source).optional }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:ordered_quantity).to(:stock) }
    it { is_expected.to delegate_method(:reserved_quantity).to(:stock) }
    it { is_expected.to delegate_method(:damaged_quantity).to(:stock) }
    it { is_expected.to delegate_method(:returned_quantity).to(:stock) }
    it { is_expected.to delegate_method(:restocked_quantity).to(:stock) }
    it { is_expected.to delegate_method(:restockable_quantity).to(:stock) }
    it { is_expected.to delegate_method(:available_quantity).to(:stock) }
    it { is_expected.to delegate_method(:adjusted_quantity).to(:stock) }
    it { is_expected.to delegate_method(:allocated_quantity).to(:stock) }
    it { is_expected.to delegate_method(:used_quantity).to(:stock) }
  end

  describe "validations" do
    describe "#batch_number" do
      it { is_expected.to validate_presence_of(:batch_number) }
      it { is_expected.to validate_length_of(:batch_number).is_at_most(55) }
    end

    describe "#lot_number" do
      it { is_expected.to validate_length_of(:lot_number).is_at_most(55).allow_blank }
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
        let(:purchase_order_item) { create(:purchase_order_item, :delivered) }

        it "is valid" do
          inventory_batch.source = purchase_order_item
          inventory_batch.quantity = 1.0
          inventory_batch.validate

          expect(inventory_batch.errors[:quantity]).to be_empty
        end
      end
    end

    describe "#cost_price" do
      before { allow(inventory_batch).to receive(:auto_fill_cost_and_currency) }

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

    describe "#location" do
      it { is_expected.to validate_presence_of(:location) }
      it { is_expected.to validate_length_of(:location).is_at_most(55) }
    end

    describe "#notes" do
      it { is_expected.to validate_length_of(:notes).is_at_most(1000).allow_blank }
    end
  end

  describe "class methods and scopes" do
    describe ".by_batch_lot_and_expiry" do
      let(:inventory) { create(:inventory) }
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }

      let!(:batch_with_expiry) { create(:inventory_batch, inventory:, batch_number: "B001", lot_number: "L001", expiration_date: 1.year.from_now, source: purchase_order_item) }
      let!(:batch_without_expiry) { create(:inventory_batch, inventory:, batch_number: "B002", lot_number: "L001", expiration_date: nil, source: purchase_order_item) }

      it "finds batch with matching batch_number and expiration_date" do
        batch = described_class.by_batch_lot_and_expiry("B001", "L001", 1.year.from_now).first

        expect(batch).to eq(batch_with_expiry)
      end

      it "finds batch with nil expiration_date" do
        batch = described_class.by_batch_lot_and_expiry("B002", "L001", nil).first

        expect(batch).to eq(batch_without_expiry)
      end

      it "returns nil if no batch matches the batch_number and expiration_date" do
        batch = described_class.by_batch_lot_and_expiry("B001", "L001", Date.tomorrow).first

        expect(batch).to be_nil
      end
    end
  end

  describe "instance methods" do
    describe "#update_inventory_average_cost_price" do
      let(:inventory) { create(:inventory) }
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let(:inventory_batch) { build(:inventory_batch, source: purchase_order_item, inventory:) }

      it "calls Inventories::UpdateAverageCostPriceService with the inventory" do
        expect(Inventories::UpdateAverageCostPriceService).to receive(:call).with(inventory)

        inventory_batch.save! # triggers after_save callback
      end
    end

    describe "#convert_to_inventory_unit" do
      let!(:dozen_item_conversion) { create(:dozen_item_conversion) }

      let(:source_unit) { dozen_item_conversion.source_unit }
      let(:target_unit) { dozen_item_conversion.target_unit }
      let(:inventory) { create(:inventory, unit: target_unit) }
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }

      context "when source and target units are the same" do
        let(:inventory_batch) { build(:inventory_batch, source: purchase_order_item, unit: target_unit, quantity: 10, inventory:) }

        it "does not change quantity or unit" do
          inventory_batch.save!

          expect(inventory_batch.quantity).to eq(10)
          expect(inventory_batch.unit).to eq(target_unit)
        end
      end

      context "when source and target units are different and conversion succeeds" do
        let(:inventory_batch) { build(:inventory_batch, source: purchase_order_item, unit: source_unit, quantity: 5, inventory:) }

        it "converts the quantity and sets unit to target unit" do
          inventory_batch.save!

          expect(inventory_batch.quantity).to eq(60)
          expect(inventory_batch.unit).to eq(target_unit)
        end
      end
    end

    describe "#previous_quantity" do
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let(:inventory_batch) { create(:inventory_batch, source: purchase_order_item) }

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
        let(:new_batch) { build(:inventory_batch, quantity: 5.0, source: purchase_order_item) }

        it "returns 0.0 for new records" do
          expect(new_batch.previous_quantity).to eq(0.0)
        end
      end
    end

    describe "#quantity_change" do
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let!(:inventory_batch) { create(:inventory_batch, quantity: 10, source: purchase_order_item) }

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
      let!(:dozen_item_conversion) { create(:dozen_item_conversion) }

      let(:source_unit) { dozen_item_conversion.source_unit }
      let(:target_unit) { dozen_item_conversion.target_unit }
      let(:inventory) { create(:inventory, unit: target_unit) }
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let(:inventory_batch) { create(:inventory_batch, unit: target_unit, inventory:, source: purchase_order_item) }

      context "when source_unit is not provided" do
        it "adds quantity directly and saves the batch" do
          expect {
            inventory_batch.merge_with!(quantity: 5)
          }.to change { inventory_batch.reload.quantity }.by(5)
        end
      end

      context "when source_unit is different from batch unit" do
        it "converts quantity before adding and saves the batch" do
          expect {
            inventory_batch.merge_with!(quantity: 2, source_unit:)
          }.to change { inventory_batch.reload.quantity }.by(24)
        end
      end

      context "when source_unit is same as batch unit" do
        it "adds quantity without conversion and saves the batch" do
          expect {
            inventory_batch.merge_with!(quantity: 3, source_unit: target_unit)
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

    describe "#manual_restock?" do
      context "when source is nil" do
        subject(:inventory_batch) { build(:inventory_batch, source: nil) }

        it "returns true" do
          expect(inventory_batch.send(:manual_restock?)).to be_truthy
        end
      end

      context "when source is present" do
        let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
        subject(:inventory_batch) { build(:inventory_batch, source: purchase_order_item) }

        it "returns false" do
          expect(inventory_batch.send(:manual_restock?)).to be_falsy
        end
      end
    end

    describe "#from_purchase_order_item?" do
      context "when source is nil" do
        subject(:inventory_batch) { build(:inventory_batch, source: nil) }

        it "returns true" do
          expect(inventory_batch.send(:from_purchase_order_item?)).to be_falsy
        end
      end

      context "when source is purchase order item" do
        let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
        subject(:inventory_batch) { build(:inventory_batch, source: purchase_order_item) }

        it "returns false" do
          expect(inventory_batch.send(:from_purchase_order_item?)).to be_truthy
        end
      end
    end

    describe "#auto_fill_cost_and_currency" do
      context "when source is nil (manual restock)" do
        let(:inventory_batch) { build(:inventory_batch, source: nil, cost_price: nil, currency: nil) }

        it "does not modify cost_price or currency" do
          inventory_batch.validate

          expect(inventory_batch.cost_price).to be_nil
          expect(inventory_batch.currency).to be_nil
        end
      end

      context "when source is a PurchaseOrderItem" do
        let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
        let(:inventory_batch) { build(:inventory_batch, source: purchase_order_item, cost_price: nil, currency: nil) }

        it "sets cost_price and currency from the source" do
          inventory_batch.validate

          expect(inventory_batch.cost_price).to eq(purchase_order_item.unit_cost)
          expect(inventory_batch.currency).to eq(purchase_order_item.currency)
        end

        it "does not overwrite existing values" do
          inventory_batch.cost_price = 123.45
          inventory_batch.currency = "USD"

          inventory_batch.validate

          expect(inventory_batch.cost_price).to eq(123.45)
          expect(inventory_batch.currency).to eq("USD")
        end
      end
    end

    describe "#record_audit_logs" do
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let!(:inventory_batch) { create(:inventory_batch, quantity: 10.0, source: purchase_order_item) }

      context "when quantity has changed" do
        it "calls InventoryBatchAuditLogs::CreateService" do
          expect(InventoryBatchAuditLogs::CreateService).to receive(:call).with(an_instance_of(InventoryBatch))

          create(:inventory_batch, quantity: 10.0, source: purchase_order_item)
        end
      end

      context "when quantity has not changed" do
        it "does not call the audit log service" do
          expect(InventoryBatchAuditLogs::CreateService).not_to receive(:call)

          inventory_batch.touch # triggers save but not quantity change
        end
      end
    end

    describe "#quantity_does_not_exceed_item_received_quantity" do
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let(:inventory_batch) do
        build(:inventory_batch, source: purchase_order_item, unit: purchase_order_item.unit, quantity: 100)
      end

      context "when converted quantity exceeds available quantity" do
        before { allow(purchase_order_item).to receive(:available_batch_quantity) { 50 } }

        it "adds an error on quantity" do
          inventory_batch.validate

          expect(inventory_batch.errors[:quantity]).to include("exceeds the available quantity for this item")
        end
      end

      context "when converted quantity is within limit" do
        before { allow(purchase_order_item).to receive(:available_batch_quantity) { 150 } }

        it "does not add any errors" do
          inventory_batch.validate

          expect(inventory_batch.errors[:quantity]).to be_empty
        end
      end
    end

    describe "#create_stock" do
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }

      it "calls InventoryBatches::Stocks::CreateService" do
        expect(InventoryBatches::Stocks::CreateService).to receive(:call).with(an_instance_of(InventoryBatch))

        create(:inventory_batch, source: purchase_order_item)
      end

      it "creates stock after batch is created" do
        expect {
          create(:inventory_batch, source: purchase_order_item)
        }.to change(InventoryBatch::Stock, :count).by(1)
      end
    end

    describe "#unique_batch_in_inventory" do
      let(:inventory) { create(:inventory) }
      let(:source) { create(:purchase_order_item, :delivered) }

      let!(:existing) { create(:inventory_batch, batch_number: "B001", lot_number: "L001", inventory:, source:) }

      context "when duplicate batch number and lot number in the same inventory" do
        let(:duplicate) { build(:inventory_batch, batch_number: "B001", lot_number: "L001", inventory:) }

        it "is invalid" do
          duplicate.validate

          expect(duplicate.errors[:batch_number]).to include("with this lot number already exists")
        end
      end

      context "when duplicate batch number without lot_number" do
        let!(:existing) { create(:inventory_batch, batch_number: "B001", lot_number: nil, inventory:, source:) }
        let(:duplicate) { build(:inventory_batch, batch_number: "B001", lot_number: nil, inventory:) }

        it "is invalid" do
          duplicate.validate

          expect(duplicate.errors[:batch_number]).to include("already exists in this inventory")
        end
      end

      context "when different batch numbers with same lot number" do
        let(:duplicate) { build(:inventory_batch, batch_number: "B002", lot_number: "L001", inventory:) }

        it "is valid" do
          duplicate.validate

          expect(duplicate.errors[:batch_number]).to be_empty
        end
      end

      context "when lot number is not present" do
        let(:duplicate) { build(:inventory_batch, batch_number: "B001", lot_number: nil, inventory:) }

        it "is valid" do
          duplicate.validate

          expect(duplicate.errors[:batch_number]).to be_empty
        end
      end

      context "when inventory is different" do
        let(:duplicate) { build(:inventory_batch, batch_number: "B001", lot_number: "L001", inventory: create(:inventory)) }

        it "is valid" do
          duplicate.validate

          expect(duplicate.errors[:batch_number]).to be_empty
        end
      end
    end

    describe "#manufactured_at_before_expiration_date" do
      subject(:inventory_batch) { build(:inventory_batch, manufactured_at:, expiration_date:) }

      context "when manufactured_at is after expiration_date" do
        let(:manufactured_at) { Date.tomorrow }
        let(:expiration_date) { Date.current }

        it "is invalid" do
          inventory_batch.validate

          expect(inventory_batch.errors[:manufactured_at]).to include("must be on or before the expiry date")
        end
      end

      context "when manufactured_at is before or equal to expiration_date" do
        let(:manufactured_at) { Date.current }
        let(:expiration_date) { Date.current }

        it "is valid" do
          inventory_batch.validate

          expect(inventory_batch.errors[:manufactured_at]).to be_empty
        end
      end

      context "when manufactured_at is nil" do
        let(:manufactured_at) { nil }
        let(:expiration_date) { Date.current }

        it "is valid" do
          inventory_batch.validate

          expect(inventory_batch.errors[:manufactured_at]).to be_empty
        end
      end
    end

    describe "#received_at_after_manufactured_at" do
      subject(:inventory_batch) { build(:inventory_batch, manufactured_at:, received_at:) }

      context "when received_at is before manufactured_at" do
        let(:manufactured_at) { Date.current }
        let(:received_at) { Date.yesterday }

        it "is invalid" do
          inventory_batch.validate

          expect(inventory_batch.errors[:received_at]).to include("must be on or after the manufacture date")
        end
      end

      context "when received_at is equal or after manufactured_at" do
        let(:manufactured_at) { Date.current }
        let(:received_at) { Date.tomorrow }

        it "is valid" do
          inventory_batch.validate

          expect(inventory_batch.errors[:received_at]).to be_empty
        end
      end

      context "when received_at is nil" do
        let(:manufactured_at) { Date.current }
        let(:received_at) { nil }

        it "is valid" do
          inventory_batch.lot_number = nil
          inventory_batch.validate

          expect(inventory_batch.errors[:received_at]).to be_empty
        end
      end
    end
  end
end
