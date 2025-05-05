# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order_item/delivery_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrder::Item::Delivery, type: :model do
  subject(:delivery) { build(:po_item_delivery, quantity: 1) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:po_item_delivery) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:item_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:quantity) }
    it { is_expected.to have_db_index(:item_id) }
    it { is_expected.to have_db_index(:unit_id) }

    it { is_expected.to have_foreign_key(:item_id).with_name(:fk_purchase_order_item_deliveries_item_id_on_purchase_order_ite).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_purchase_order_item_deliveries_unit_id_on_units).on_delete(:restrict) }

    it { is_expected.to have_check_constraint(:check_purchase_order_item_deliveries_quantity_positive).with_expression("quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_purchase_order_item_deliveries_quantity_presence).with_expression("quantity IS NOT NULL") }
  end

  describe "included modules" do
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:quantity) }
  end

  describe "associations" do
    before do
      allow(delivery).to receive(:convert_to_item_unit)
      allow(delivery).to receive(:converted_quantity_must_not_exceed_remaining_quantity)
    end

    it { is_expected.to belong_to(:item).class_name("PurchaseOrder::Item").inverse_of(:deliveries) }
    it { is_expected.to belong_to(:unit).inverse_of(:delivered_po_items) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :validation, :store_original_attributes) }
    it { is_expected.to have_callback(:before, :validation, :convert_to_item_unit) }
    it { is_expected.to have_callback(:after, :create, :process_delivery) }
  end

  describe "validations" do
    before { allow(delivery).to receive(:convert_to_item_unit) }

    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }

      context "when quantity is invalid" do
        let(:delivery) { build(:po_item_delivery, quantity: "abcd") }

        it "is invalid" do
          delivery.validate

          expect(delivery.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity <= 0.0" do
        let(:delivery) { build(:po_item_delivery, quantity: 0.0) }

        it "is invalid" do
          delivery.validate

          expect(delivery.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity > 0.0" do
        let(:delivery) { build(:po_item_delivery, quantity: 1.0) }

        it "is valid" do
          delivery.validate

          expect(delivery.errors[:quantity]).to be_empty
        end
      end
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end
  end

  describe "instance methods" do
    let!(:source_unit) { create(:dozen_unit) }
    let!(:target_unit) { create(:item_unit) }

    let(:item) { create(:purchase_order_item, quantity: 12, unit: target_unit) }

    describe "#convert_to_item_unit" do
      before { allow(delivery).to receive(:process_delivery) }

      context "when source and target units are the same" do
        let(:delivery) { build(:po_item_delivery, unit: target_unit, quantity: 10, item:) }

        it "does not change quantity or unit" do
          expect(UnitConversion).not_to receive(:convert)

          delivery.save!

          expect(delivery.quantity).to eq(10)
          expect(delivery.unit).to eq(target_unit)
        end
      end

      context "when source and target units are different and conversion succeeds" do
        let(:delivery) { build(:po_item_delivery, unit: source_unit, quantity: 1, item:) }

        it "converts the quantity and sets unit to target unit" do
          allow(UnitConversion).to receive(:convert).with(source_unit, target_unit, 1) { 12 }

          delivery.save!

          expect(delivery.quantity).to eq(12)
          expect(delivery.unit).to eq(target_unit)
        end
      end
    end

    describe "#process_delivery" do
      let(:delivery) { build(:po_item_delivery, item:) }

      it "calls PurchaseOrders::Items::Deliveries::ProcessService with the delivery" do
        expect(PurchaseOrders::Items::Deliveries::ProcessService).to receive(:call).with(delivery)

        delivery.save!
      end
    end

    describe "#store_original_attributes" do
      let(:delivery) { build(:po_item_delivery, quantity: 5, unit: source_unit) }

      before { allow(UnitConversion).to receive(:convert) }

      it "stores original quantity and unit_id before conversion" do
        expect(delivery.original_quantity).to be_nil
        expect(delivery.original_unit_id).to be_nil

        delivery.validate

        expect(delivery.original_quantity).to eq(5)
        expect(delivery.original_unit_id).to eq(source_unit.id)
      end

      it "does not override existing original values" do
        delivery.original_quantity = 3
        delivery.original_unit_id = target_unit.id

        delivery.validate

        expect(delivery.original_quantity).to eq(3)
        expect(delivery.original_unit_id).to eq(target_unit.id)
      end
    end

    describe "#converted_quantity_must_not_exceed_remaining_quantity" do
      context "when converted quantity exceeds remaining quantity" do
        let(:delivery) { build(:po_item_delivery, quantity: 10, unit: source_unit, item:) }

        before do
          allow(UnitConversion).to receive(:convert) { 20 } # Converted to 20 items
          allow(delivery.item).to receive(:remaining_quantity) { 15 }
        end

        it "adds an error to quantity" do
          delivery.validate

          expect(delivery.errors[:quantity]).to include("cannot exceed remaining quantity of the purchase order item")
        end
      end

      context "when converted quantity is within remaining quantity" do
        let(:delivery) do
          build(
            :po_item_delivery,
            quantity: 10,
            unit: source_unit,
            item: item
          )
        end

        before do
          allow(UnitConversion).to receive(:convert) { 10 }
          allow(delivery.item).to receive(:remaining_quantity) { 15 }
        end

        it "does not add an error" do
          delivery.validate

          expect(delivery.errors[:quantity]).to be_empty
        end
      end
    end
  end
end
