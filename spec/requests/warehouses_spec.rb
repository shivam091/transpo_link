# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/warehouses_spec.rb

require "spec_helper"

RSpec.describe "Warehouses", type: :request do
  let!(:active_warehouse) { create(:warehouse, :active) }
  let!(:inactive_warehouse) { create(:warehouse) }

  let(:valid_attributes) do
    attributes_for(:warehouse, name: "New warehouse").merge(
      manager_ids: active_warehouse.manager_ids,
      supplier_ids: active_warehouse.supplier_ids,
      unit_id: active_warehouse.unit.id
    )
  end
  let(:invalid_attributes) { attributes_for(:warehouse, name: "") }

  include_context "sign in as admin"

  describe "GET /warehouses" do
    it "renders list of all warehouses with pagination" do
      get warehouses_path

      expect(controller_assigns(:warehouses)).to include(active_warehouse)
      expect(controller_assigns(:warehouses)).to include(inactive_warehouse)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of active warehouses with pagination" do
      get active_warehouses_path

      expect(controller_assigns(:warehouses)).to include(active_warehouse)
      expect(controller_assigns(:warehouses)).to exclude(inactive_warehouse)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of inactive warehouses with pagination" do
      get inactive_warehouses_path

      expect(controller_assigns(:warehouses)).to include(inactive_warehouse)
      expect(controller_assigns(:warehouses)).to exclude(active_warehouse)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /warehouses/new" do
    before { get new_warehouse_path }

    include_examples "initializes a new instance", :warehouse, Warehouse
  end

  describe "POST /warehouses" do
    context "when provided attributes are valid" do
      it "creates the warehouse and redirects" do
        post warehouses_path, params: {warehouse: valid_attributes}, as: :turbo_stream

        expect(flash[:notice]).to eq("Warehouse was successfully created.")
        expect(response).to redirect_to(warehouses_path)
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided attributes are invalid" do
      it "does not create the warehouse and renders errors" do
        post warehouses_path, params: {warehouse: invalid_attributes}, as: :turbo_stream

        expect(flash[:alert]).to eq("Warehouse could not be created.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_warehouse_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /warehouses/:id/edit" do
    it "renders warehouse edit page" do
      get edit_warehouse_path(active_warehouse)

      expect(controller_assigns(:warehouse)).to eq(active_warehouse)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /warehouses/:id" do
    context "when provided attributes are valid" do
      it "updates the warehouse and redirects" do
        expect {
          put warehouse_path(active_warehouse), params: {warehouse: valid_attributes}, as: :turbo_stream
        }.to change { active_warehouse.reload.name }.to("New warehouse")

        expect(response).to redirect_to(warehouses_path)
        expect(flash[:notice]).to eq("Warehouse was successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided attributes are invalid" do
      it "does not update the warehouse and renders errors" do
        expect {
          put warehouse_path(active_warehouse), params: {warehouse: invalid_attributes}, as: :turbo_stream
        }.to not_change { active_warehouse.reload.name }

        expect(flash[:alert]).to eq("Warehouse could not be updated.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_warehouse_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /warehouse/:id" do
    it "renders warehouse details page" do
      get warehouse_path(active_warehouse)

      expect(controller_assigns(:warehouse)).to eq(active_warehouse)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /warehouse/:id" do
    context "when valid id" do
      it "deletes the warehouse and redirects" do
        delete warehouse_path(active_warehouse)

        expect(response).to redirect_to(warehouses_path)
        expect(flash[:info]).to eq("Warehouse was successfully deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when delete fails" do
      it "does not delete the warehouse and redirects with an error message" do
        allow(Warehouses::DestroyService).to receive(:call) { ServiceResponse.error }

        delete warehouse_path(active_warehouse)

        expect(response).to redirect_to(warehouses_path)
        expect(flash[:alert]).to eq("Warehouse could not be deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
