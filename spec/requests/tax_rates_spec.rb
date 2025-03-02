# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/tax_rates_spec.rb

require "spec_helper"

RSpec.describe "TaxRates", type: :request do
  let!(:tax_rate) { create(:tax_rate) }

  let(:valid_attributes) { attributes_for(:tax_rate, tax_type: "tin") }
  let(:invalid_attributes) { attributes_for(:tax_rate, tax_type: "") }

  context "when user is not signed in" do
    describe "GET /tax-rates" do
      subject { get tax_rates_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /tax-rates/new" do
      subject { get new_tax_rate_path }

      it { is_expected.to require_sign_in }
    end

    describe "POST /tax-rates" do
      subject { post tax_rates_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /tax-rates/:id/edit" do
      subject { get edit_tax_rate_path(tax_rate) }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /tax-rates/:id" do
      subject { put tax_rate_path(tax_rate) }

      it { is_expected.to require_sign_in }
    end

    describe "DELETE /tax-rates/:id" do
      subject { delete tax_rate_path(tax_rate) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /tax-rates" do
      before { get tax_rates_path }

      it "renders user list and returns :ok status" do
        expect(controller_assigns(:tax_rates)).to be_present
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(controller_assigns(:tax_rates)).to include(tax_rate)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /tax-rates/new" do
      before { get new_tax_rate_path }

      include_examples "initializes a new instance", :tax_rate, TaxRate

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /tax-rates" do
      context "when valid attributes" do
        it "creates the tax rate" do
          post tax_rates_path, params: {tax_rate: valid_attributes}, as: :turbo_stream

          expect(flash[:notice]).to eq("Tax rate was successfully created.")
          expect(response).to redirect_to(tax_rates_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid attributes" do
        it "does not create new tax rate" do
          post tax_rates_path, params: {tax_rate: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Tax rate could not be created.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_tax_rate_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /tax-rates/:id/edit" do
      it "returns :ok status" do
        get edit_tax_rate_path(tax_rate)

        expect(controller_assigns(:tax_rate)).to eq(tax_rate)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /tax-rates/:id" do
      context "when valid attributes" do
        it "updates the tax rate" do
          put tax_rate_path(tax_rate), params: {tax_rate: valid_attributes}, as: :turbo_stream

          expect(tax_rate.reload.tax_type).to eq("tin")
          expect(flash[:notice]).to eq("Tax rate was successfully updated.")
          expect(response).to redirect_to(tax_rates_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid attributes" do
        it "does not update the tax rate" do
          put tax_rate_path(tax_rate), params: {tax_rate: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Tax rate could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_tax_rate_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /tax-rates/:id" do
      context "when valid id" do
        it "deletes the tax rate" do
          delete tax_rate_path(tax_rate)

          expect(response).to redirect_to(tax_rates_path)
          expect(flash[:info]).to eq("Tax rate was successfully deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when invalid id" do
        let(:service_response) { ServiceResponse.error(message: "Tax rate could not be deleted.") }

        before do
          allow(TaxRates::DestroyService).to receive(:call) { service_response }
        end

        it "redirects with an error message" do
          delete tax_rate_path(tax_rate)

          expect(response).to redirect_to(tax_rates_path)
          expect(flash[:alert]).to eq("Tax rate could not be deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end
end
