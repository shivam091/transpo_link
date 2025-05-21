# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/purchase_orders/approvals_spec.rb

require "spec_helper"

RSpec.describe "PurchaseOrders::Approvals", type: :request do
  let!(:purchase_order) { create(:purchase_order, :with_po_items) }

  let(:valid_params) { {approval: attributes_for(:purchase_order_approval)} }
  let(:invalid_params) { {approval: attributes_for(:purchase_order_approval, reference_document: "")} }

  include_context "sign in as supplier"

  before { grant_permission!(supplier, :purchase_orders, :approve) }

  describe "GET /purchase-orders/:purchase_order_id/approval/new" do
    before { get new_purchase_order_approval_path(purchase_order), as: :turbo_stream }

    include_examples "initializes a new instance", :approval, PurchaseOrder::Approval

    it "renders new purchase order approval confirmation modal" do
      expect(response.body).to include("<turbo-frame id=\"po_approval_confirmation_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /purchase-orders/:purchase_order_id/approval" do
    context "when provided parameters are valid" do
      it "approves the purchase order and redirects" do
        post purchase_order_approval_path(purchase_order), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("Purchase order has been successfully approved.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not approve the purchase order and renders errors" do
        post purchase_order_approval_path(purchase_order), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Unable to approve the purchase order. Please try again later or contact support if the issue persists.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"po_approval_confirmation_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
