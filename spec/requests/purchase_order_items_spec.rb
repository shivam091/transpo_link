# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/purchase_order_items_spec.rb

require "spec_helper"

RSpec.describe "PurchaseOrderItems", type: :request do
  let(:purchase_order) { create(:purchase_order) }

  let!(:po_item1) { create(:purchase_order_item, purchase_order:) }
  let!(:po_item2) { create(:purchase_order_item, purchase_order:) }

  include_context "sign in as manager"

  describe "GET /purchase-orders/:purchase_order_id/purchase-order-items" do
    it "renders list of all purchase order items" do
      get purchase_order_purchase_order_items_path(purchase_order)

      expect(controller_assigns(:purchase_order)).to eq(purchase_order)
      expect(controller_assigns(:purchase_order_items)).to match_array([po_item1, po_item2])
      expect(response).to have_http_status(:ok)
    end
  end
end
