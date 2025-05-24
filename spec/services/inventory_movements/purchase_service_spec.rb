# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_movements/purchase_service_spec.rb

require "spec_helper"

RSpec.describe InventoryMovements::PurchaseService, type: :service do
  let!(:inventory) { create(:inventory) }
  let!(:source) { create(:purchase_order_item, quantity: 5) }

  subject(:service_response) { described_class.(inventory, source, inventory_movement_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:inventory_movement_attributes) do
        {
          quantity: source.quantity,
          unit_id: source.unit_id,
          unit_cost: source.unit_cost,
          total_cost: source.total_cost,
          currency: source.currency
        }
      end

      include_examples "creates a record", InventoryMovement

      it "sets correct inventory movement attributes for purchase" do
        inventory_movement = service_response.payload[:inventory_movement]

        expect(inventory_movement.movement_type).to eq("purchase")
        expect(inventory_movement.inventory).to eq(inventory)
        expect(inventory_movement.source).to eq(source)
        expect(inventory_movement.quantity).to eq(5.0)
        expect(inventory_movement.unit_id).to eq(source.unit_id)
      end

      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:inventory_movement_attributes) { { quantity: nil, unit_id: nil } }

      include_examples "does not change record count", InventoryMovement
      include_examples "returns an error response"
    end
  end
end
