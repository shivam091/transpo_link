# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/update_average_cost_price_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::UpdateAverageCostPriceService, type: :service do
  let(:purchase_order_item) do
    create(:purchase_order_item, :delivered, quantity: 1000, received_quantity: 1000)
  end
  let(:inventory) do
    create(:inventory).tap do |inventory|
      create(:inventory_batch, quantity: 100, cost_price: 10.0, source: purchase_order_item, inventory:)
      create(:inventory_batch, quantity: 200, cost_price: 12.0, source: purchase_order_item, inventory:)
      create(:inventory_batch, quantity: 150, cost_price: 11.0, source: purchase_order_item, inventory:)
    end
  end

  let(:expected_average_cost_price) do
    total_cost = (100 * 10.0) + (200 * 12.0) + (150 * 11.0)
    total_quantity = 100 + 200 + 150
    total_cost / total_quantity
  end

  include_context "with current user"

  subject(:service_response) { described_class.(inventory) }

  before { allow_any_instance_of(InventoryBatch).to receive(:update_inventory_average_cost_price) }

  describe ".call" do
    it "calculates & updates the average cost price" do
      expect {
        service_response
      }.to change {
        inventory.reload.average_cost_price
      }.to be_within(0.01).of(expected_average_cost_price)
    end
  end
end
