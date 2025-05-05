# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/movements/purchase_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::Movements::PurchaseService, type: :service do
  let!(:inventory) { create(:inventory) }
  let!(:source) { create(:purchase_order_item, quantity: 5) }

  subject(:service_response) { described_class.call(inventory, source, movement_attributes) }

  describe ".call" do
    context "with valid attributes" do
      let(:movement_attributes) do
        {
          quantity: source.quantity,
          unit_id: source.unit_id,
          unit_cost: source.unit_cost,
          total_cost: source.total_cost,
          currency: source.currency
        }
      end

      include_examples "creates a record", Inventory::Movement

      it "sets correct inventory movement attributes for purchase" do
        movement = service_response.payload[:movement]

        expect(movement.type).to eq("purchase")
        expect(movement.inventory).to eq(inventory)
        expect(movement.source).to eq(source)
        expect(movement.quantity).to eq(5.0)
        expect(movement.unit_id).to eq(source.unit_id)
      end

      include_examples "returns a success response"
    end

    context "with invalid attributes" do
      let(:movement_attributes) { { quantity: nil, unit_id: nil } }

      include_examples "does not change record count", Inventory::Movement
      include_examples "returns an error response"
    end
  end
end
