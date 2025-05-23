# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/stock_adjustments_spec.rb

require "spec_helper"

RSpec.describe "StockAdjustments", type: :request do
  include_context "sign in as admin"

  let!(:inventory) { create(:inventory) }
  let(:valid_params) { {stock_adjustment: attributes_for(:stock_adjustment, unit_id: inventory.unit_id, user_id: admin.id)} }
  let(:invalid_params) { {stock_adjustment: attributes_for(:stock_adjustment, unit_id: nil)} }

  describe "GET /adjustable/:adjustable_id/stock-adjustments/new" do
    before do
      get new_inventory_stock_adjustment_path(inventory), as: :turbo_stream
    end

    include_examples "initializes a new instance", :stock_adjustment, StockAdjustment

    it "renders new stock adjustment modal" do
      expect(response.body).to include("<turbo-frame id=\"new_stock_adjustment_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /adjustable/:adjustable_id/stock-adjustments" do
    context "when provided parameters are valid" do
      it "adjusts the stock and redirects" do
        post inventory_stock_adjustments_path(inventory), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(inventories_path)
        expect(flash[:notice]).to eq("Stock was successfully adjusted.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not adjust the stock and renders errors" do
        post inventory_stock_adjustments_path(inventory), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Unable to adjust the stock. Please try again later or contact support if the issue persists.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_stock_adjustment_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
