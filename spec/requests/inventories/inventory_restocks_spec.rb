# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/inventories/inventory_restocks_spec.rb

require "spec_helper"

RSpec.describe "Inventories::InventoryRestocks", type: :request do
  let(:unit) { create(:item_unit) }
  let(:purchase_order_item) { create(:purchase_order_item, :delivered, unit:) }
  let(:inventory_batch) { create(:inventory_batch, quantity: 10, source: purchase_order_item, unit:) }

  let(:valid_params) { {inventory_restock: attributes_for(:inventory_restock, unit_id: unit.id, inventory_batch_id: inventory_batch.id)} }
  let(:invalid_params) { {inventory_restock: attributes_for(:inventory_restock, comment: "")} }

  include_context "sign in as manager"

  before { allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs) }

  describe "GET /inventory-batches/:inventory_batch_id/restocks/new" do
    before { get new_inventory_batch_inventory_restock_path(inventory_batch), as: :turbo_stream }

    include_examples "initializes a new instance", :inventory_restock, Inventory::Restock

    it "renders inventory restock modal" do
      expect(response.body).to include("<turbo-frame id=\"inventory_restock_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /inventory-batches/:inventory_batch_id/restocks" do
    context "when provided parameters are valid" do
      it "restocks the inventory and redirects" do
        post inventory_batch_inventory_restocks_path(inventory_batch), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(inventories_path)
        expect(flash[:notice]).to eq("The inventory has been successfully restocked.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not restock the inventory and renders errors" do
        post inventory_batch_inventory_restocks_path(inventory_batch), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Unable to restock the inventory. Please try again later or contact support if the issue persists.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"inventory_restock_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
