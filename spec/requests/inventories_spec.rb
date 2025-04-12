# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/inventories_spec.rb

require "spec_helper"

RSpec.describe "Inventories", type: :request do
  let(:unit) { create(:acre_unit) }
  let(:product) { create(:product, unit:) }
  let(:warehouse) { create(:warehouse) }
  let(:another_product) { create(:product, unit:) }

  let!(:inventory) { create(:inventory, warehouse:, product:, unit:) }

  let(:valid_attributes) { attributes_for(:inventory, currency: "INR", product_id: another_product.id, warehouse_id: warehouse.id, unit_id: unit.id) }
  let(:invalid_attributes) { attributes_for(:inventory, currency: nil) }

  include_context "sign in as admin"

  describe "GET /inventories" do
    it "renders list of all inventories with pagination" do
      get inventories_path

      expect(controller_assigns(:inventories)).to include(inventory)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /inventories/new" do
    before { get new_inventory_path }

    include_examples "initializes a new instance", :inventory, Inventory
  end

  describe "POST /inventories" do
    context "when provided attributes are valid" do
      it "creates the inventory and redirects" do
        post inventories_path, params: {inventory: valid_attributes}, as: :turbo_stream

        expect(response).to redirect_to(inventories_path)
        expect(flash[:notice]).to eq("Inventory has been successfully created.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided attributes are invalid" do
      it "does not create the inventory and renders errors" do
        post inventories_path, params: {inventory: invalid_attributes}, as: :turbo_stream

        expect(flash[:alert]).to eq("We encountered a problem creating inventory. Please try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_inventory_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /inventories/:id/edit" do
    it "renders inventory edit page" do
      get edit_inventory_path(inventory)

      expect(controller_assigns(:inventory)).to eq(inventory)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /inventories/:id" do
    context "when provided attributes are valid" do
      it "updates the inventory and redirects" do
        expect {
          put inventory_path(inventory), params: {inventory: valid_attributes}, as: :turbo_stream
        }.to change { inventory.reload.currency }.to("INR")

        expect(response).to redirect_to(inventories_path)
        expect(flash[:notice]).to eq("Inventory has been successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided attributes are invalid" do
      it "does not update the inventory and renders errors" do
        expect {
          put inventory_path(inventory), params: {inventory: invalid_attributes}, as: :turbo_stream
        }.to not_change { inventory.reload.currency }

        expect(flash[:alert]).to eq("We encountered a problem updating inventory. Please try again.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_inventory_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /inventories/:id" do
    it "renders inventory details page" do
      get inventory_path(inventory)

      expect(controller_assigns(:inventory)).to eq(inventory)
      expect(response).to have_http_status(:ok)
    end
  end
end
