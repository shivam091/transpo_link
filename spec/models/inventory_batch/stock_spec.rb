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

  describe "state machines" do
    it { is_expected.to have_state(:available) }
    it { is_expected.to transition_from(:available).to(:reserved).on_event(:reserve) }
    it { is_expected.to transition_from(:available).to(:partially_used).on_event(:consume_partially) }
    it { is_expected.to transition_from(:reserved).to(:partially_used).on_event(:consume_partially) }
    it { is_expected.to transition_from(:available).to(:exhausted).on_event(:consume_fully) }
    it { is_expected.to transition_from(:reserved).to(:exhausted).on_event(:consume_fully) }
    it { is_expected.to transition_from(:partially_used).to(:exhausted).on_event(:consume_fully) }
    it { is_expected.to transition_from(:available).to(:locked).on_event(:lock) }
    it { is_expected.to transition_from(:reserved).to(:locked).on_event(:lock) }
    it { is_expected.to transition_from(:partially_used).to(:locked).on_event(:lock) }
    it { is_expected.to transition_from(:exhausted).to(:locked).on_event(:lock) }
    it { is_expected.to transition_from(:available).to(:damaged).on_event(:damage) }
    it { is_expected.to transition_from(:reserved).to(:damaged).on_event(:damage) }
    it { is_expected.to transition_from(:exhausted).to(:closed).on_event(:close) }
    it { is_expected.to transition_from(:locked).to(:closed).on_event(:close) }
  end

  describe "validations" do
    describe "#ordered_quantity" do
      it { is_expected.to validate_presence_of(:ordered_quantity) }

      context "when ordered_quantity < 0.0" do
        it "is invalid" do
          inventory_batch_stock.ordered_quantity = -0.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:ordered_quantity]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when ordered_quantity >= 0.0" do
        it "is valid" do
          inventory_batch_stock.ordered_quantity = 0.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:ordered_quantity]).to be_empty
        end
      end
    end

    describe "#reserved_quantity" do
      it { is_expected.to validate_presence_of(:reserved_quantity) }

      context "when reserved_quantity < 0.0" do
        it "is invalid" do
          inventory_batch_stock.reserved_quantity = -0.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:reserved_quantity]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when reserved_quantity >= 0.0" do
        it "is valid" do
          inventory_batch_stock.reserved_quantity = 0.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:reserved_quantity]).to be_empty
        end
      end
    end

    describe "#damaged_quantity" do
      it { is_expected.to validate_presence_of(:damaged_quantity) }

      context "when damaged_quantity < 0.0" do
        it "is invalid" do
          inventory_batch_stock.damaged_quantity = -0.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:damaged_quantity]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when damaged_quantity >= 0.0" do
        it "is valid" do
          inventory_batch_stock.damaged_quantity = 0.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:damaged_quantity]).to be_empty
        end
      end
    end

    describe "#returned_quantity" do
      it { is_expected.to validate_presence_of(:returned_quantity) }

      context "when returned_quantity < 0.0" do
        it "is invalid" do
          inventory_batch_stock.returned_quantity = -0.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:returned_quantity]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when returned_quantity >= 0.0" do
        it "is valid" do
          inventory_batch_stock.returned_quantity = 0.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:returned_quantity]).to be_empty
        end
      end
    end

    describe "#restocked_quantity" do
      it { is_expected.to validate_presence_of(:restocked_quantity) }

      context "when restocked_quantity < 0.0" do
        it "is invalid" do
          inventory_batch_stock.restocked_quantity = -0.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:restocked_quantity]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when restocked_quantity >= 0.0" do
        it "is valid" do
          inventory_batch_stock.restocked_quantity = 0.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:restocked_quantity]).to be_empty
        end
      end
    end

    describe "#restockable_quantity" do
      it { is_expected.to validate_presence_of(:restockable_quantity) }

      context "when restockable_quantity < 0.0" do
        it "is invalid" do
          inventory_batch_stock.restockable_quantity = -0.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:restockable_quantity]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when restockable_quantity >= 0.0" do
        it "is valid" do
          inventory_batch_stock.restockable_quantity = 0.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:restockable_quantity]).to be_empty
        end
      end
    end

    describe "#available_quantity" do
      it { is_expected.to validate_presence_of(:available_quantity) }

      context "when available_quantity < 0.0" do
        it "is invalid" do
          inventory_batch_stock.available_quantity = -0.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:available_quantity]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when available_quantity >= 0.0" do
        it "is valid" do
          inventory_batch_stock.available_quantity = 0.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:available_quantity]).to be_empty
        end
      end
    end

    describe "#used_quantity" do
      it { is_expected.to validate_presence_of(:used_quantity) }

      context "when used_quantity < 0.0" do
        it "is invalid" do
          inventory_batch_stock.used_quantity = -0.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:used_quantity]).to include("must be greater than or equal to 0.0")
        end
      end

      context "when used_quantity >= 0.0" do
        it "is valid" do
          inventory_batch_stock.used_quantity = 0.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:used_quantity]).to be_empty
        end
      end
    end

    describe "#status" do
      it { is_expected.to validate_presence_of(:status) }

      it "allows valid status values" do
        described_class.statuses.keys.each do |valid_status|
          expect(build(:inventory_batch_stock, status: valid_status)).to be_valid
        end
      end

      it "raises error on invalid status value" do
        expect {
          build(:inventory_batch_stock, status: "invalid_status")
        }.to raise_error(ArgumentError, /is not a valid status/)
      end
    end
  end

  describe "instance methods" do
    let(:purchase_order_item) { create(:purchase_order_item, :delivered, quantity: 100, received_quantity: 1000) }
    let(:inventory_batch) { create(:inventory_batch, quantity: 100, source: purchase_order_item) }
    let(:stock) { inventory_batch.stock }

    include_context "with current user"

    describe "#recalculate_quantities" do
      it "recalculates restockable_quantity and available_quantity" do
        expect(inventory_batch.restockable_quantity).to eq(100.0)
        expect(inventory_batch.available_quantity).to eq(100.0)

        stock.update!(restocked_quantity: 30, used_quantity: 20)

        expect(inventory_batch.restockable_quantity).to eq(70.0) # 100 - 30
        expect(inventory_batch.available_quantity).to eq(80.0) # 100 - 20
      end
    end

    describe "#auto_update_status" do
      it "sets status to :available when stock is unused" do
        expect(stock.status).to eq("available")
      end

      it "sets status to :locked when is_locked is true" do
        stock.update!(is_locked: true)

        expect(stock.status).to eq("locked")
      end

      it "sets status to :exhausted when available_quantity is 0.0" do
        stock.update!(used_quantity: 100)

        expect(stock.status).to eq("exhausted")
      end

      it "sets status to :partially_used when reserved_quantity > 0.0" do
        stock.update!(reserved_quantity: 5)

        expect(stock.status).to eq("partially_used")
      end

      it "sets status to :partially_used when ordered_quantity > 0.0" do
        stock.update!(ordered_quantity: 5)

        expect(stock.status).to eq("partially_used")
      end

      it "sets status to :closed when exhausted and used_quantity >= batch quantity" do
        stock.update!(status: :exhausted, used_quantity: 100)

        expect(stock.status).to eq("closed")
      end

      it "does not change status if already locked" do
        stock.update!(status: :locked, is_locked: false)

        expect(stock.status).to eq("locked")
      end
    end

    describe "#prevent_updates_if_locked" do
      it "prevents update if locked and modifying restricted fields" do
        expect {
          stock.update!(is_locked: true, reserved_quantity: 10)
        }.to raise_error(ActiveRecord::RecordNotSaved)

        expect(stock.errors[:base]).to include("cannot modify a locked batch")
      end

      it "allows update if locked but modifying non restricted fields" do
        expect {
          stock.update!(is_locked: true, used_quantity: 5)
        }.not_to raise_error
      end
    end

    describe "#restocked_quantity_less_than_batch_quantity" do
      let(:inventory_batch) { build(:inventory_batch, quantity: 10.0) }

      before { allow(inventory_batch_stock).to receive(:inventory_batch) { inventory_batch } }

      context "when restocked_quantity is less than or equal to inventory_batch quantity" do
        it "is valid" do
          inventory_batch_stock.restocked_quantity = 9.5
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:restocked_quantity]).to be_empty
        end
      end

      context "when restocked_quantity is greater than inventory_batch quantity" do
        it "is invalid" do
          inventory_batch_stock.restocked_quantity = 12.0
          inventory_batch_stock.validate

          expect(inventory_batch_stock.errors[:restocked_quantity]).to include("exceeds batch quantity")
        end
      end
    end
  end
end
