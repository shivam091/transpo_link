# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/purchase_orders_spec.rb

require "spec_helper"

RSpec.describe "PurchaseOrders", type: :request do
  include_context "sign in as manager"

  let(:supplier) { create(:supplier) }

  let!(:purchase_order) { create(:purchase_order, manager:, supplier:) }

  let(:valid_params) do
    {
      purchase_order: attributes_for(:purchase_order,
        warehouse_id: purchase_order.warehouse.id,
        manager_id: manager.id,
        supplier_id: purchase_order.supplier.id
      )
    }
  end
  let(:invalid_params) { {purchase_order: {warehouse_id: nil, manager_id: nil, supplier_id: nil}} }

  describe "GET /purchase-orders" do
    it "renders list of all purchase orders with pagination" do
      get purchase_orders_path

      expect(controller_assigns(:purchase_orders)).to include(purchase_order)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /purchase-orders/new" do
    before { get new_purchase_order_path }

    include_examples "initializes a new instance", :purchase_order, PurchaseOrder
  end

  describe "POST /purchase-orders" do
    context "when provided parameters are valid" do
      it "creates the purchase order and redirects" do
        post purchase_orders_path, params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("Purchase order has been successfully created.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not create the purchase order and renders errors" do
        post purchase_orders_path, params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("We encountered a problem creating purchase order. Please try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_purchase_order_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /purchase-orders/:id/edit" do
    it "renders purchase order edit page" do
      get edit_purchase_order_path(purchase_order)

      expect(controller_assigns(:purchase_order)).to eq(purchase_order)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /purchase-orders/:id" do
    context "when provided parameters are valid" do
      it "updates the purchase order and redirects" do
        put purchase_order_path(purchase_order), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("Purchase order has been successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not update the purchase order and renders errors" do
        put purchase_order_path(purchase_order), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("We encountered a problem updating purchase order. Please try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_purchase_order_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /purchase-orders/:id" do
    it "renders purchase order details page" do
      get purchase_order_path(purchase_order)

      expect(controller_assigns(:purchase_order)).to eq(purchase_order)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /purchase-orders/:id" do
    context "when deletion is successful" do
      it "deletes the purchase order and redirects" do
        delete purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:info]).to eq("Purchase order has been successfully deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when deletion is unsuccessful" do
      it "does not delete the purchase order and redirects with an error message" do
        allow(PurchaseOrders::DestroyService).to receive(:call) { ServiceResponse.error }

        delete purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:alert]).to eq("We encountered a problem deleting purchase order. Please try again.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "PATCH /purchase-orders/:id/cancel" do
    context "when cancellation is successful" do
      it "cancels the purchase order and redirects" do
        patch cancel_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:info]).to eq("Purchase order has been successfully cancelled.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when cancellation is unsuccessful" do
      it "does not cancel the purchase order and redirects with an error message" do
        allow(PurchaseOrders::CancelService).to receive(:call) { ServiceResponse.error }

        patch cancel_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:alert]).to eq("We encountered a problem cancelling purchase order. Please try again.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "PATCH /purchase-orders/:id/submit" do
    context "when submission is successful" do
      it "submits the purchase order and redirects" do
        patch submit_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:info]).to eq("Purchase order has been successfully submitted to the supplier for approval.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when submission is unsuccessful" do
      it "does not submit the purchase order and redirects with an error message" do
        allow(PurchaseOrders::SubmitService).to receive(:call) { ServiceResponse.error }

        patch submit_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:alert]).to eq("We encountered a problem submitting purchase order. Please try again.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
