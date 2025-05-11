# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/purchase_order_items/inventory_batches_spec.rb

require "spec_helper"

RSpec.describe "PurchaseOrderItems::InventoryBatches", type: :request do
  let!(:unit_conversion) { create(:dozen_item_conversion) }

  let(:unit) { unit_conversion.target_unit }
  let(:inventory) { create(:inventory, unit:) }
  let(:warehouse) { inventory.warehouse }
  let(:product) { inventory.product }

  let!(:purchase_order) { create(:purchase_order, warehouse:) }
  let!(:purchase_order_item) { create(:purchase_order_item, quantity: 5, received_quantity: 100, purchase_order:, unit:, product:) }

  let(:valid_params) { {inventory_batch: attributes_for(:inventory_batch, unit_id: unit.id, quantity: 10)} }
  let(:invalid_params) { {inventory_batch: attributes_for(:inventory_batch, quantity: nil, unit_id: nil)} }

  include_context "sign in as manager"

  describe "GET /purchase-order-items/:purchase_order_item_id/inventory-batches/new" do
    before { get new_purchase_order_item_inventory_batch_path(purchase_order_item), as: :turbo_stream }

    include_examples "initializes a new instance", :inventory_batch, InventoryBatch

    it "renders new inventory batch modal" do
      expect(response.body).to include("<turbo-frame id=\"new_inventory_batch_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /purchase-order-items/:purchase_order_item_id/inventory-batches" do
    context "when provided parameters are valid" do
      it "creates the inventory batch and redirects" do
        post purchase_order_item_inventory_batches_path(purchase_order_item), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("The inventory batch has been successfully created.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not create the inventory batch and renders errors" do
        post purchase_order_item_inventory_batches_path(purchase_order_item), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("We encountered a problem creating the inventory batch. Please try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_inventory_batch_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
