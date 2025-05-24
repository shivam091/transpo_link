# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/inventories/inventory_batches/stock_adjustments_spec.rb

require "spec_helper"

RSpec.describe "Inventories::InventoryBatches::StockAdjustments", type: :request do
  include_context "sign in as admin"

  let(:inventory_batch) { create(:inventory_batch) }
  let(:valid_params) { {stock_adjustment: attributes_for(:stock_adjustment, unit_id: inventory_batch.unit_id, user_id: admin.id)} }
  let(:invalid_params) { {stock_adjustment: attributes_for(:stock_adjustment, unit_id: nil)} }

  before do
    allow_any_instance_of(InventoryBatch).to receive(:record_audit_logs)
    allow_any_instance_of(InventoryBatch).to receive(:validate_quantity_does_not_exceed_item_received_quantity)
  end

  describe "GET /inventory-batches/:inventory_batch_id/stock-adjustments/new" do
    before do
      get new_inventory_batch_stock_adjustment_path(inventory_batch), as: :turbo_stream
    end

    include_examples "initializes a new instance", :stock_adjustment, StockAdjustment

    it "renders new stock adjustment modal" do
      expect(response.body).to include("<turbo-frame id=\"new_stock_adjustment_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /inventory-batches/:inventory_batch_id/stock-adjustments" do
    context "when provided parameters are valid" do
      it "adjusts the stock and redirects" do
        post inventory_batch_stock_adjustments_path(inventory_batch), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(inventories_path)
        expect(flash[:notice]).to eq("Stock was successfully adjusted.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not adjust the stock and renders errors" do
        post inventory_batch_stock_adjustments_path(inventory_batch), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Unable to adjust the stock. Please try again later or contact support if the issue persists.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_stock_adjustment_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
