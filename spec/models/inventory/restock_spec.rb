# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory/restock_spec.rb

require "spec_helper"

RSpec.describe Inventory::Restock, type: :model do
  subject(:inventory_restock) { build(:inventory_restock) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_restock) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:quantity) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:note) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:comment) }
    it { is_expected.to sanitize_attribute(:note) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:after, :create, :restock_inventory) }
  end

  describe "associations" do
    it { is_expected.to have_many(:inventory_movements).dependent(:destroy) }

    it { is_expected.to belong_to(:inventory_batch).inverse_of(:restocks) }
    it { is_expected.to belong_to(:unit).inverse_of(:restocks) }
  end

  describe "validations" do
    let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
    let(:inventory_batch) { create(:inventory_batch, source: purchase_order_item) }

    before do
      allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs)
      allow(inventory_restock).to receive(:inventory_batch) { inventory_batch }
    end

    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }

      context "when quantity is invalid" do
        let(:inventory_restock) { build(:inventory_restock, quantity: "abcd") }

        it "is invalid" do
          inventory_restock.validate

          expect(inventory_restock.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity <= 0.0" do
        let(:inventory_restock) { build(:inventory_restock, quantity: 0.0) }

        it "is invalid" do
          inventory_restock.validate

          expect(inventory_restock.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity > 0.0" do
        let(:inventory_restock) { build(:inventory_restock, quantity: 1.0) }

        it "is valid" do
          inventory_restock.validate

          expect(inventory_restock.errors[:quantity]).to be_empty
        end
      end
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end

    describe "#comment" do
      it { is_expected.to validate_presence_of(:comment) }
      it { is_expected.to validate_length_of(:comment).is_at_most(1000) }
    end

    describe "#note" do
      it { is_expected.to validate_length_of(:note).is_at_most(1000).allow_blank }
    end
  end

  describe "instance methods" do
    before { allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs) }

    describe "#restock_inventory" do
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let(:inventory_batch) { create(:inventory_batch, source: purchase_order_item) }

      it "calls Inventories::RestockService" do
        expect(Inventories::RestockService).to receive(:call).with(an_instance_of(InventoryBatch), an_instance_of(Inventory::Restock))

        create(:inventory_restock, inventory_batch:)
      end
    end

    describe "#quantity_cannot_exceed_stock_restockable_quantity" do
      let(:purchase_order_item) { create(:purchase_order_item, :delivered) }
      let(:inventory_batch) { create(:inventory_batch, source: purchase_order_item) }

      before { allow(inventory_restock).to receive(:inventory_batch) { inventory_batch } }

      context "when restocked_quantity is less than or equal to inventory_batch quantity" do
        it "is valid" do
          inventory_restock.quantity = 9.5
          inventory_restock.validate

          expect(inventory_restock.errors[:quantity]).to be_empty
        end
      end

      context "when restocked_quantity is greater than inventory_batch quantity" do
        it "is invalid" do
          inventory_restock.quantity = 12.0
          inventory_restock.validate

          expect(inventory_restock.errors[:quantity]).to include("exceeds the restockable quantity of the batch")
        end
      end
    end
  end
end
