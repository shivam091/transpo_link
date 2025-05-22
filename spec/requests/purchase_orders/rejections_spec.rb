# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/purchase_orders/rejections_spec.rb

require "spec_helper"

RSpec.describe "PurchaseOrders::Rejections", type: :request do
  let!(:purchase_order) { create(:purchase_order) }

  let(:valid_params) { {rejection: attributes_for(:purchase_order_rejection)} }
  let(:invalid_params) { {rejection: attributes_for(:purchase_order_rejection, reason: "")} }

  include_context "sign in as supplier"

  before { grant_permission!(supplier, :purchase_orders, :reject) }

  describe "GET /purchase-orders/:purchase_order_id/rejection/new" do
    before { get new_purchase_order_rejection_path(purchase_order), as: :turbo_stream }

    include_examples "initializes a new instance", :rejection, PurchaseOrder::Rejection

    it "renders new purchase order rejection confirmation modal" do
      expect(response.body).to include("<turbo-frame id=\"po_rejection_confirmation_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /purchase-orders/:purchase_order_id/rejection" do
    context "when provided parameters are valid" do
      it "rejects the purchase order and redirects" do
        post purchase_order_rejection_path(purchase_order), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("Purchase order has been successfully rejected.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not reject the purchase order and renders errors" do
        post purchase_order_rejection_path(purchase_order), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Unable to reject the purchase order. Please try again later or contact support if the issue persists.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"po_rejection_confirmation_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
