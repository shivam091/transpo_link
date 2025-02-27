# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/warehouses_spec.rb

require "spec_helper"

RSpec.describe "Warehouses", type: :request do
  let!(:warehouse) { create(:warehouse, :active) }
  let(:valid_attributes) { attributes_for(:warehouse) }
  let(:invalid_attributes) { attributes_for(:warehouse, name: "") }

  context "when user is not signed in" do
    describe "GET /warehouses" do
      subject { get warehouses_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /warehouses/new" do
      subject { get new_warehouse_path }

      it { is_expected.to require_sign_in }
    end

    describe "POST /warehouses" do
      subject { post warehouses_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /warehouses/:id/edit" do
      subject { get edit_warehouse_path(warehouse) }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /warehouses/:id" do
      subject { put warehouse_path(warehouse) }

      it { is_expected.to require_sign_in }
    end

    describe "GET /warehouses/:id" do
      subject { get warehouse_path(warehouse) }

      it { is_expected.to require_sign_in }
    end

    describe "DELETE /warehouses/:id" do
      subject { delete warehouse_path(warehouse) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /warehouses" do
      before { get warehouses_path }

      it "renders user list and returns :ok status" do
        expect(controller_assigns(:warehouses)).to be_present
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(controller_assigns(:warehouses).reload).to include(warehouse)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /warehouses/new" do
      before { get new_warehouse_path }

      include_examples "initializes a new instance", :warehouse, Warehouse

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /warehouses" do
      context "when valid attributes" do
        it "creates the warehouse" do
          post warehouses_path, params: {warehouse: valid_attributes}, as: :turbo_stream

          expect(flash[:notice]).to eq("Warehouse was successfully created.")
          expect(response).to redirect_to(warehouses_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid attributes" do
        it "does not create new warehouse" do
          post warehouses_path, params: {warehouse: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Warehouse could not be created.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"warehouse_form\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /warehouses/:id/edit" do
      it "returns :ok status" do
        get edit_warehouse_path(warehouse)

        expect(controller_assigns(:warehouse)).to eq(warehouse)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /warehouses/:id" do
      context "when valid attributes" do
        it "updates the warehouse" do
          put warehouse_path(warehouse), params: {
            warehouse: attributes_for(:warehouse, name: "New warehouse")
          }, as: :turbo_stream

          expect(warehouse.reload.name).to eq("New warehouse")
          expect(flash[:notice]).to eq("Warehouse was successfully updated.")
          expect(response).to redirect_to(warehouses_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid attributes" do
        it "does not update the warehouse" do
          put warehouse_path(warehouse), params: {warehouse: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Warehouse could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"warehouse_form\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /warehouse/:id" do
      it "renders warehouse details page" do
        get warehouse_path(warehouse)

        expect(response.body).to include("<div class='widget-help'>")
        expect(response).to have_http_status(:ok)
      end
    end

    describe "DELETE /warehouse/:id" do
      context "when valid id" do
        it "deletes the warehouse" do
          delete warehouse_path(warehouse)

          expect(response).to redirect_to(warehouses_path)
          expect(flash[:info]).to eq("Warehouse was successfully deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid id" do
        let(:service_response) { ServiceResponse.error(message: "Warehouse could not be deleted.") }

        before do
          allow(Warehouses::DestroyService).to receive(:call).and_return(service_response)
        end

        it "redirects with an error message" do
          delete warehouse_path(warehouse)

          expect(response).to redirect_to(warehouses_path)
          expect(flash[:alert]).to eq("Warehouse could not be deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end
end
