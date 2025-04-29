# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/purchase_order_items/deliveries_spec.rb

require "spec_helper"

RSpec.describe "PurchaseOrderItems::Deliveries", type: :request do
  let!(:product) { create(:product) }
  let!(:warehouse) { create(:warehouse) }
  let!(:inventory) { create(:inventory, product:, warehouse:) }

  let(:purchase_order) { create(:purchase_order, :submitted, warehouse:) }
  let(:purchase_order_item) { create(:purchase_order_item, product:, purchase_order:) }

  let(:valid_params) { {inventory_batch: attributes_for(:inventory_batch, unit_id: inventory.unit_id)} }
  let(:invalid_params) { {inventory_batch: attributes_for(:inventory_batch)} }

  include_context "sign in as manager"

  describe "GET /purchase-orders/:purchase_order_id/purchase-order-items/:purchase_order_item_id/delivery/new" do
    before { get new_purchase_order_purchase_order_item_delivery_path(purchase_order, purchase_order_item) }

    include_examples "initializes a new instance", :inventory_batch, InventoryBatch

    it "renders new purchase order item delivery modal" do
      expect(response.body).to include("<turbo-frame id=\"new_purchase_order_item_delivery_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /purchase-orders/:purchase_order_id/purchase-order-items/:purchase_order_item_id/delivery" do
    context "when provided parameters are valid" do
      it "creates the inventory batch and redirects" do
        post purchase_order_purchase_order_item_delivery_path(purchase_order, purchase_order_item), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("The item delivery has been recorded and is being processed. It will be available for use shortly.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not create the inventory batch and renders errors" do
        post purchase_order_purchase_order_item_delivery_path(purchase_order, purchase_order_item), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Unable to record the item delivery. Please check the details and try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_purchase_order_item_delivery_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
