# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/tax_details_spec.rb

require "spec_helper"

RSpec.describe "TaxDetails", type: :request do
  let!(:buyer) { create(:buyer) }
  let!(:tax_detail) { create(:tax_detail, user: buyer) }

  let(:valid_attributes) { attributes_for(:tax_detail, tax_number: "ABCDE1234A").merge(user_id: buyer.id) }
  let(:invalid_attributes) { attributes_for(:tax_detail, tax_number: "") }

  context "when user is not signed in" do
    describe "GET /tax-details" do
      subject { get tax_details_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /tax-details/new" do
      subject { get new_tax_detail_path }

      it { is_expected.to require_sign_in }
    end

    describe "POST /tax-details" do
      subject { post tax_details_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /tax-details/:id/edit" do
      subject { get edit_tax_detail_path(tax_detail) }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /tax-details/:id" do
      subject { put tax_detail_path(tax_detail) }

      it { is_expected.to require_sign_in }
    end

    describe "DELETE /tax-details/:id" do
      subject { delete tax_detail_path(tax_detail) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as buyer"

    describe "GET /tax-details" do
      before { get tax_details_path }

      it "renders tax details list and returns :ok status" do
        expect(controller_assigns(:tax_details)).to be_present
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(controller_assigns(:tax_details)).to include(tax_detail)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /tax-details/new" do
      before { get new_tax_detail_path }

      include_examples "initializes a new instance", :tax_detail, TaxDetail

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /tax-details" do
      context "when valid attributes" do
        it "creates the tax detail" do
          post tax_details_path, params: {tax_detail: valid_attributes}, as: :turbo_stream

          expect(flash[:notice]).to eq("Tax detail was successfully created.")
          expect(response).to redirect_to(tax_details_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid attributes" do
        it "does not create new tax detail" do
          post tax_details_path, params: {tax_detail: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Tax detail could not be created.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_tax_detail_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /tax-details/:id/edit" do
      it "returns :ok status" do
        get edit_tax_detail_path(tax_detail)

        expect(controller_assigns(:tax_detail)).to eq(tax_detail)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /tax-details/:id" do
      context "when valid attributes" do
        it "updates the tax detail" do
          put tax_detail_path(tax_detail), params: {tax_detail: valid_attributes}, as: :turbo_stream

          expect(tax_detail.reload.tax_number).to eq("ABCDE1234A")
          expect(flash[:notice]).to eq("Tax detail was successfully updated.")
          expect(response).to redirect_to(tax_details_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid attributes" do
        it "does not update the tax detail" do
          put tax_detail_path(tax_detail), params: {tax_detail: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Tax detail could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_tax_detail_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /tax-details/:id" do
      context "when valid id" do
        it "deletes the tax detail" do
          delete tax_detail_path(tax_detail)

          expect(response).to redirect_to(tax_details_path)
          expect(flash[:info]).to eq("Tax detail was successfully deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid id" do
        let(:service_response) { ServiceResponse.error(message: "Tax detail could not be deleted.") }

        before do
          allow(TaxDetails::DestroyService).to receive(:call) { service_response }
        end

        it "redirects with an error message" do
          delete tax_detail_path(tax_detail)

          expect(response).to redirect_to(tax_details_path)
          expect(flash[:alert]).to eq("Tax detail could not be deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end
end
