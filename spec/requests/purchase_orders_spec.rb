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
      grant_permission!(manager, :purchase_orders, :view_all)

      get purchase_orders_path

      expect(controller_assigns(:purchase_orders)).to include(purchase_order)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /purchase-orders/new" do
    before do
      grant_permission!(manager, :purchase_orders, :create)
      get new_purchase_order_path
    end

    include_examples "initializes a new instance", :purchase_order, PurchaseOrder
  end

  describe "POST /purchase-orders" do
    before { grant_permission!(manager, :purchase_orders, :create) }

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
      grant_permission!(manager, :purchase_orders, :update)

      get edit_purchase_order_path(purchase_order)

      expect(controller_assigns(:purchase_order)).to eq(purchase_order)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /purchase-orders/:id" do
    before { grant_permission!(manager, :purchase_orders, :update) }

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
      grant_permission!(manager, :purchase_orders, :view)

      get purchase_order_path(purchase_order)

      expect(controller_assigns(:purchase_order)).to eq(purchase_order)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /purchase-orders/:id" do
    before { grant_permission!(manager, :purchase_orders, :delete) }

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
    before { grant_permission!(manager, :purchase_orders, :cancel) }

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
    before { grant_permission!(manager, :purchase_orders, :submit) }

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

  describe "PATCH /purchase-orders/:id/approve" do
    let(:warehouse) { create(:warehouse, :with_supplier, name: "Test warehouse") }
    let(:product) { create(:product, name: "Test product") }
    let(:unit) { product.unit }
    let(:supplier) { warehouse.suppliers.first }

    let!(:purchase_order) do
      create(:purchase_order, :submitted, warehouse:, manager:, supplier:).tap do |po|
        create(:purchase_order_item, purchase_order: po, product:, unit:)
      end
    end

    before { grant_permission!(manager, :purchase_orders, :approve) }

    context "when inventory exists and unit conversion is successful" do
      before { create(:inventory, warehouse:, product:, unit:) }

      it "approves the purchase order and redirects" do
        patch approve_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:info]).to eq("Purchase order has been successfully approved.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when inventory is missing" do
      it "does not approve the purchase order and redirects with a missing inventory error" do
        patch approve_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Inventory is missing for the product "Test product" in the warehouse "Test warehouse".')
        expect(response).to have_http_status(:found)
      end
    end

    context "when unit conversion fails" do
      before do
        create(:inventory, warehouse:, product:, unit:)
        allow(UnitConversion).to receive(:convert!).and_raise(UnitConversionError.new(unit, unit))
      end

      it "does not approve the purchase order and redirects with an unit conversion error" do
        patch approve_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Cannot convert from "Item" to "Item". Please ensure a valid unit conversion exists.')
        expect(response).to have_http_status(:found)
      end
    end

    context "when approval is unsuccessful" do
      it "does not approve the purchase order and redirects with an error message" do
        allow(PurchaseOrders::ApproveService).to receive(:call) { ServiceResponse.error }

        patch approve_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:alert]).to eq("We encountered a problem approving purchase order. Please try again.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "PATCH /purchase-orders/:id/reject" do
    let!(:purchase_order) { create(:purchase_order, :submitted, manager:) }

    before { grant_permission!(manager, :purchase_orders, :reject) }

    context "when rejection is successful" do
      it "rejects the purchase order and redirects" do
        patch reject_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:info]).to eq("Purchase order has been successfully rejected.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when rejection is unsuccessful" do
      it "does not reject the purchase order and redirects with an error message" do
        allow(PurchaseOrders::RejectService).to receive(:call) { ServiceResponse.error }

        patch reject_purchase_order_path(purchase_order), as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:alert]).to eq("We encountered a problem rejecting purchase order. Please try again.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
