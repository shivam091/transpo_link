# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/inventory_batches/restocks_spec.rb

require "spec_helper"

RSpec.describe "InventoryBatches::Restocks", type: :request do
  include_context "sign in as manager"

  let(:unit) { create(:item_unit) }
  let(:source) { create(:purchase_order_item, :delivered, unit:) }
  let(:inventory_batch) { create(:inventory_batch, source:, unit:) }

  let(:valid_params) do
    {
      restock: attributes_for(:inventory_restock,
        unit_id: unit.id,
        inventory_batch_id: inventory_batch.id,
        user_id: manager.id
      )
    }
  end
  let(:invalid_params) { {restock: attributes_for(:inventory_restock, comment: "")} }

  before { allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs) }

  describe "GET /inventory-batches/:inventory_batch_id/restocks/new" do
    before do
      grant_permission!(manager, :inventories, :restock)
      get new_inventory_batch_restock_path(inventory_batch), as: :turbo_stream
    end

    include_examples "initializes a new instance", :restock, Inventory::Restock

    it "renders inventory restock modal" do
      expect(response.body).to include("<turbo-frame id=\"inventory_batch_restock_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /inventory-batches/:inventory_batch_id/restocks" do
    before { grant_permission!(manager, :inventories, :restock) }

    context "when provided parameters are valid" do
      it "restocks the inventory and redirects" do
        post inventory_batch_restocks_path(inventory_batch), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(inventories_path)
        expect(flash[:notice]).to eq("The inventory has been successfully restocked.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not restock the inventory and renders errors" do
        post inventory_batch_restocks_path(inventory_batch), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Unable to restock the inventory. Please try again later or contact support if the issue persists.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"inventory_batch_restock_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
