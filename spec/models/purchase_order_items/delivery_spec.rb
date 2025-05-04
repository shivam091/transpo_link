# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order_items/delivery_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::Delivery, type: :model do
  subject(:po_item_delivery) { build(:po_item_delivery) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:po_item_delivery) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:purchase_order_item_id).of_type(:uuid) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:quantity) }
    it { is_expected.to have_db_index(:purchase_order_item_id) }
    it { is_expected.to have_db_index(:unit_id) }

    it { is_expected.to have_foreign_key(:purchase_order_item_id).with_name(:fk_purchase_order_item_deliveries_purchase_order_item_id_on_pur).on_delete(:cascade) }
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
    it { is_expected.to belong_to(:purchase_order_item).inverse_of(:deliveries) }
    it { is_expected.to belong_to(:unit).inverse_of(:delivered_po_items) }
  end

  describe "callbacks" do
    it { is_expected.to have_callback(:before, :create, :convert_to_item_unit) }
  end

  describe "validations" do
    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }

      context "when quantity is invalid" do
        let(:delivery) { described_class.new(quantity: "abcd") }

        it "is invalid" do
          delivery.validate

          expect(delivery.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity <= 0.0" do
        let(:delivery) { described_class.new(quantity: 0.0) }

        it "is invalid" do
          delivery.validate

          expect(delivery.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity > 0.0" do
        let(:delivery) { described_class.new(quantity: 1.0) }

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

    let(:purchase_order_item) { create(:purchase_order_item, unit: target_unit) }

    describe "#convert_to_item_unit" do
      context "when source and target units are the same" do
        let(:delivery) { build(:po_item_delivery, purchase_order_item:, unit: target_unit, quantity: 10) }

        it "does not change quantity or unit" do
          expect(UnitConversion).not_to receive(:convert)

          delivery.save!

          expect(delivery.quantity).to eq(10)
          expect(delivery.unit).to eq(target_unit)
        end
      end

      context "when source and target units are different and conversion succeeds" do
        let(:delivery) { build(:po_item_delivery, purchase_order_item:, unit: source_unit, quantity: 5) }

        it "converts the quantity and sets unit to target unit" do
          allow(UnitConversion).to receive(:convert).with(source_unit, target_unit, 5) { 60 }

          delivery.save!

          expect(delivery.quantity).to eq(60)
          expect(delivery.unit).to eq(target_unit)
        end
      end
    end
  end
end
