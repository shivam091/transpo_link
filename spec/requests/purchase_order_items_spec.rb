# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/purchase_order_items_spec.rb

require "spec_helper"

RSpec.describe "PurchaseOrderItems", type: :request do
  let(:purchase_order) { create(:purchase_order) }
  let(:product) { create(:product) }
  let(:unit) { product.unit }

  let!(:po_item1) { create(:purchase_order_item, purchase_order:) }
  let!(:po_item2) { create(:purchase_order_item, purchase_order:) }

  let(:valid_params) do
    {
      purchase_order_item: attributes_for(:purchase_order_item,
        product_id: product.id,
        unit_id: unit.id
      )
    }
  end
  let(:invalid_params) { {purchase_order_item: attributes_for(:purchase_order_item, quantity: nil)} }

  include_context "sign in as manager"

  describe "GET /purchase-orders/:purchase_order_id/purchase-order-items" do
    it "renders list of all purchase order items" do
      get purchase_order_purchase_order_items_path(purchase_order)

      expect(controller_assigns(:purchase_order)).to eq(purchase_order)
      expect(controller_assigns(:purchase_order_items)).to match_array([po_item1, po_item2])
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /purchase-orders/:purchase_order_id/purchase-order-items/new" do
    before { get new_purchase_order_purchase_order_item_path(purchase_order) }

    include_examples "initializes a new instance", :purchase_order_item, PurchaseOrder::Item

    it "renders new purchase order item modal" do
      expect(response.body).to include("<turbo-frame id=\"new_purchase_order_item_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /purchase-orders/:purchase_order_id/purchase-order-items" do
    context "when provided parameters are valid" do
      it "creates the purchase order item and closes the modal" do
        post purchase_order_purchase_order_items_path(purchase_order), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("Purchase order item has been successfully added.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not create the purchase order item and renders errors" do
        post purchase_order_purchase_order_items_path(purchase_order), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("We encountered a problem creating the purchase order item. Please try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_purchase_order_item_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /purchase-order-items/:id/edit" do
    it "renders edit purchase order item modal" do
      get edit_purchase_order_item_path(po_item1)

      expect(controller_assigns(:purchase_order_item)).to eq(po_item1)
      expect(response.body).to include("<turbo-frame id=\"edit_purchase_order_item_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /purchase-order-items/:id" do
    context "when provided parameters are valid" do
      it "updates the purchase order item and closes the modal" do
        patch purchase_order_item_path(po_item1), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("Purchase order item has been successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not update the purchase order item and renders errors" do
        patch purchase_order_item_path(po_item1), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("We encountered a problem updating the purchase order item. Please try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_purchase_order_item_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /purchase-order-items/:id" do
    it "renders purchase order item details modal" do
      get purchase_order_item_path(po_item1)

      expect(controller_assigns(:purchase_order_item)).to eq(po_item1)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /purchase-order-items/:id" do
    context "when deletion is successful" do
      it "deletes the purchase order item and redirects" do
        delete purchase_order_item_path(po_item1), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("Purchase order item has been successfully deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when deletion is successful" do
      it "does not delete the purchase order item and render errors" do
        allow(PurchaseOrderItems::DestroyService).to receive(:call) { ServiceResponse.error }

        delete purchase_order_item_path(po_item1), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:alert]).to eq("We encountered a problem deleting the purchase order item. Please try again.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "PATCH /purchase-order-items/:id/cancel" do
    context "when cancellation is successful" do
      it "cancels the purchase order item and redirects" do
        patch cancel_purchase_order_item_path(po_item1), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("Purchase order item has been successfully cancelled.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when cancellation is unsuccessful" do
      it "does not cancel the purchase order item and render errors" do
        allow(PurchaseOrderItems::CancelService).to receive(:call) { ServiceResponse.error }

        patch cancel_purchase_order_item_path(po_item1), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:alert]).to eq("We encountered a problem cancelling the purchase order item. Please try again.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
