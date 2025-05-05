# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/purchase_order_items/deliveries_spec.rb

require "spec_helper"

RSpec.describe "PurchaseOrders::Items::Deliveries", type: :request do
  let(:unit) { create(:dozen_unit) }
  let(:valid_params) { {delivery: {quantity: 12, unit_id: unit.id}} }
  let(:invalid_params) { {delivery: {quantity: nil, unit_id: nil}} }

  let!(:purchase_order) { create(:purchase_order, :submitted) }
  let!(:item) { create(:purchase_order_item, purchase_order:, unit:) }

  include_context "sign in as manager"

  describe "GET /purchase-order-items/:purchase_order_item_id/deliveries/new" do
    before { get new_purchase_order_item_delivery_path(item), as: :turbo_stream }

    include_examples "initializes a new instance", :delivery, PurchaseOrder::Item::Delivery

    it "renders new purchase order item delivery modal" do
      expect(response.body).to include("<turbo-frame id=\"new_purchase_order_item_delivery_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /purchase-order-items/:purchase_order_item_id/deliveries" do
    before do
      allow_any_instance_of(PurchaseOrder::Item::Delivery).to receive(:convert_to_item_unit)
      allow_any_instance_of(PurchaseOrder::Item::Delivery).to receive(:process_delivery)
    end

    context "when provided parameters are valid" do
      it "creates the delivery and redirects" do
        post purchase_order_item_deliveries_path(item), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(purchase_orders_path)
        expect(flash[:notice]).to eq("The item delivery has been recorded.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not create the delivery and renders errors" do
        post purchase_order_item_deliveries_path(item), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Unable to record the item delivery. Please check the details and try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_purchase_order_item_delivery_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
