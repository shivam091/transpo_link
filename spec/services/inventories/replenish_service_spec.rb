# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/replenish_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::ReplenishService, type: :service do
  let(:source_unit) { create(:dozen_unit) }
  let(:target_unit) { create(:item_unit) }
  let(:warehouse) { create(:warehouse, name: "Test warehouse", unit: source_unit) }
  let(:product) { create(:product, name: "Test product", unit: source_unit) }
  let(:manager) { create(:manager) }
  let(:supplier) { create(:supplier) }

  let!(:inventory) { create(:inventory, warehouse:, product:, unit: target_unit) }
  let!(:unit_conversion) { create(:dozen_item_conversion, source_unit:, target_unit:) }

  let!(:purchase_order) do
    create(:purchase_order, :submitted, warehouse:, manager:, supplier:).tap do |po|
      create(:purchase_order_item, purchase_order: po, product:, unit: source_unit, quantity: 10)
    end
  end

  subject(:service_response) { described_class.(purchase_order) }

  context "when inventory and unit conversion exists" do
    it "increments quantity_pending_from_supplier correctly" do
      expect {
        service_response
      }.to change { inventory.replenishment.reload.quantity_pending_from_supplier }.by(120)
    end
  end

  context "when inventory is missing" do
    before { inventory.destroy }

    it "raises MissingInventoryError" do
      expect {
        service_response
      }.to raise_error(PurchaseOrders::MissingInventoryError, 'Inventory is missing for the product "Test product" in the warehouse "Test warehouse".')
    end
  end

  context "when unit conversion is missing" do
    before { UnitConversion.destroy_all }

    it "raises UnitConversionError" do
      expect {
        service_response
      }.to raise_error(UnitConversionError, 'Cannot convert from "Dozen" to "Item". Please ensure a valid unit conversion exists.')
    end
  end
end
