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
end
