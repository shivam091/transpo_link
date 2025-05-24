# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/stock_adjustment_spec.rb

require "spec_helper"

RSpec.describe StockAdjustment, type: :model do
  subject(:stock_adjustment) { build(:stock_adjustment) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:stock_adjustment) }
  end

  describe "included modules" do
    it { is_expected.to include_module(ScaleEnforcer) }
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:adjustment_type).backed_by_column_of_type(:enum) }
    it { is_expected.to define_enum_for(:adjustment_reason).backed_by_column_of_type(:enum) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:note) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:note) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:adjusted_quantity) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:adjustable).inverse_of(:stock_adjustments) }
    it { is_expected.to belong_to(:source).inverse_of(:stock_adjustments).optional }
    it { is_expected.to belong_to(:inventory).inverse_of(:stock_adjustments).optional }
    it { is_expected.to belong_to(:user).inverse_of(:stock_adjustments) }
    it { is_expected.to belong_to(:unit).inverse_of(:stock_adjustments) }
  end

  describe "validations" do
    describe "#adjusted_quantity" do
      it { is_expected.to validate_presence_of(:adjusted_quantity) }

      context "when adjusted_quantity is invalid" do
        it "is invalid" do
          stock_adjustment.adjusted_quantity = "abcd"
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjusted_quantity]).to include("must be greater than 0.0")
        end
      end

      context "when adjusted_quantity <= 0.0" do
        it "is invalid" do
          stock_adjustment.adjusted_quantity = 0.0
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjusted_quantity]).to include("must be greater than 0.0")
        end
      end

      context "when adjusted_quantity > 0.0" do
        it "is valid" do
          stock_adjustment.adjusted_quantity = 1.0
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjusted_quantity]).to be_empty
        end
      end
    end

    describe "#adjustment_type" do
      it { is_expected.to validate_presence_of(:adjustment_type) }

      it "allows valid adjustment_type values" do
        described_class.adjustment_types.keys.each do |adjustment_type|
          stock_adjustment = build(:stock_adjustment, adjustment_type:)
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjustment_type]).to be_empty
        end
      end

      it "raises error on invalid adjustment_type value" do
        expect {
          build(:stock_adjustment, adjustment_type: "invalid_adjustment_type")
        }.to raise_error(ArgumentError, /is not a valid adjustment_type/)
      end
    end

    describe "#adjustment_reason" do
      it { is_expected.to validate_presence_of(:adjustment_reason) }

      it "allows valid adjustment_reason values" do
        described_class.adjustment_reasons.keys.each do |adjustment_reason|
          stock_adjustment = build(:stock_adjustment, adjustment_reason:)
          stock_adjustment.validate

          expect(stock_adjustment.errors[:adjustment_reason]).to be_empty
        end
      end

      it "raises error on invalid adjustment_reason value" do
        expect {
          build(:stock_adjustment, adjustment_reason: "invalid_adjustment_reason")
        }.to raise_error(ArgumentError, /is not a valid adjustment_reason/)
      end
    end

    describe "#note" do
      it { is_expected.to validate_length_of(:note).is_at_most(1000).allow_blank }
    end
  end

  describe "instance methods" do
    describe "#set_inventory_id" do
      let(:user) { create(:admin) }
      let(:unit) { create(:item_unit) }
      let(:inventory) { create(:inventory, unit:) }
      let(:defaults) { {user:, unit:} }

      context "when inventory_id is already set" do
        let(:adjustment) { build(:stock_adjustment, adjustable: inventory, inventory:, **defaults) }

        it "does not override the inventory_id" do
          expect { adjustment.save! }.not_to change { adjustment.inventory_id }
          expect(adjustment.inventory_id).to eq(inventory.id)
        end
      end

      context "when adjustable responds to inventory_id" do
        let(:adjustable) { create(:inventory_batch, inventory:, unit:) }
        let(:adjustment) { build(:stock_adjustment, adjustable:, **defaults) }

        before do
          allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs)
          allow_any_instance_of(InventoryBatch).to receive(:validate_quantity_does_not_exceed_item_received_quantity)
        end

        it "sets inventory_id from the adjustable's inventory_id" do
          adjustment.save!

          expect(adjustment.inventory_id).to eq(adjustable.inventory_id)
        end
      end

      context "when adjustable has no inventory or inventory_id" do
        let(:adjustable) { create(:inventory_batch, inventory:, unit:) }
        let(:adjustment) { build(:stock_adjustment, adjustable:, **defaults) }

        before do
          allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs)
          allow_any_instance_of(InventoryBatch).to receive(:validate_quantity_does_not_exceed_item_received_quantity)

          allow(adjustable).to receive(:respond_to?) do |method, *args|
            method == :inventory_id ? false : adjustable.class.superclass.instance_method(:respond_to?).bind(adjustable).call(method, *args)
          end
        end

        it "raises ArgumentError" do
          expect { adjustment.save! }.to raise_error(ArgumentError, "Missing inventory on adjustable")
        end
      end
    end
  end
end
