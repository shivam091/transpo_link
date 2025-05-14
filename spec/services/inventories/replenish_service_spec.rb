# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/replenish_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::ReplenishService, type: :service do
  let(:unit) { create(:item_unit) }
  let(:warehouse) { create(:warehouse, unit:) }
  let(:product) { create(:product, unit:) }

  let!(:inventory) { create(:inventory, warehouse:, product:, unit:) }

  let!(:purchase_order) do
    create(:purchase_order, :submitted, warehouse:).tap do |purchase_order|
      create(:purchase_order_item, purchase_order:, product:, unit:)
    end
  end

  subject(:service_response) { described_class.(purchase_order) }

  context "when inventory and unit conversion exists" do
    it "increments quantity_pending_from_supplier correctly" do
      expect {
        service_response
      }.to change { inventory.replenishment.reload.quantity_pending_from_supplier }.by(1000)
    end
  end

  context "when inventory is missing" do
    before { inventory.destroy }

    it "raises MissingInventoryError" do
      expect {
        service_response
      }.to raise_error(PurchaseOrders::MissingInventoryError, /Inventory is missing for the product/)
    end
  end
end
