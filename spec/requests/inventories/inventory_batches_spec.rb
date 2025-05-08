# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/inventories/inventory_batches_spec.rb

require "spec_helper"

RSpec.describe "Inventories::InventoryBatches", type: :request do
  let(:inventory) { create(:inventory) }
  let(:purchase_order_item) do
    create(:purchase_order_item, :delivered, quantity: 10, received_quantity: 100, unit: inventory.unit)
  end
  let!(:batch1) { create(:inventory_batch, quantity: 2, source: purchase_order_item, inventory:) }
  let!(:batch2) { create(:inventory_batch, quantity: 2, source: purchase_order_item, inventory:) }

  include_context "sign in as manager"
  include_context "with current user"

  describe "GET /inventories/:inventory_id/inventory-batches" do
    it "renders list of all inventory batches in turbo frame" do
      get inventory_inventory_batches_path(inventory), headers: {"Turbo-Frame" => dom_id(inventory, :batches)}

      expect(controller_assigns(:inventory)).to eq(inventory)
      expect(controller_assigns(:inventory_batches)).to match_array([batch1, batch2])

      expect(response.body).to include(batch1.batch_number)
      expect(response.body).to include(batch2.batch_number)
      expect(response.body).not_to include("<html>") # Should be just a partial

      expect(response).to have_http_status(:ok)
    end
  end
end
