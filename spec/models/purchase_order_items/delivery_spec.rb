# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/purchase_order_items/delivery_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::Delivery, type: :model do
  let(:target_unit) { create(:dozen_unit) }
  let(:purchase_order_item) { create(:purchase_order_item, quantity: 100.0) }
  let(:unit) { purchase_order_item.unit }
  let!(:dozen_item_conversion) { create(:dozen_item_conversion, source_unit: unit, target_unit:) }

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

    describe "#unit" do
      it { is_expected.to validate_presence_of(:unit) }
    end
  end

  describe "#normalize_attributes" do
    it "converts quantity string to BigDecimal" do
      delivery = described_class.new(quantity: "10.5", unit: unit.id.to_s)
      delivery.validate

      expect(delivery.quantity).to eq(BigDecimal("10.5"))
    end

    it "resolves unit ID string to Unit record" do
      delivery = described_class.new(quantity: 5, unit: unit.id.to_s)
      delivery.validate

      expect(delivery.unit).to eq(unit)
    end
  end

  describe "#process!" do
    context "when invalid" do
      it "returns false" do
        delivery = described_class.new(quantity: nil, unit: nil)

        expect(delivery.process!).to be_falsy
      end
    end

    context "when valid" do
      let(:delivery) { described_class.new(purchase_order_item:, quantity: 12, unit: unit.id) }

      it "calls the delivery processing service with converted quantity" do
        allow(UnitConversion).to receive(:convert) { 12.0 }

        expect(PurchaseOrderItems::ProcessDeliveryService).to receive(:call).with(purchase_order_item, 12.0).and_call_original

        delivery.process!
      end
    end

    context "when unit is different and conversion is needed" do
      let(:delivery) { described_class.new(purchase_order_item:, quantity: 1, unit: target_unit.id) }

      it "converts quantity before passing to service" do
        converted_quantity = 12.0

        expect(UnitConversion).to receive(:convert).with(target_unit, purchase_order_item.unit, delivery.quantity) { converted_quantity }
        expect(PurchaseOrderItems::ProcessDeliveryService).to receive(:call).with(purchase_order_item, converted_quantity).and_call_original

        delivery.process!
      end
    end
  end
end
