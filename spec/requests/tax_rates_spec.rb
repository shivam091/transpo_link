# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/tax_rates_spec.rb

require "spec_helper"

RSpec.describe "TaxRates", type: :request do
  let!(:active_tax_rate) { create(:tax_rate, valid_to: Date.current + 1.day) }
  let!(:future_tax_rate) { create(:tax_rate, valid_from: (Date.current + 1.week)) }

  let!(:valid_attributes) { attributes_for(:tax_rate, tax_identifier_type: "pan") }
  let!(:invalid_attributes) { attributes_for(:tax_rate, tax_identifier_type: "") }

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
      subject { get edit_tax_rate_path(active_tax_rate) }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /tax-rates/:id" do
      subject { put tax_rate_path(active_tax_rate) }

      it { is_expected.to require_sign_in }
    end

    describe "DELETE /tax-rates/:id" do
      subject { delete tax_rate_path(active_tax_rate) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /tax-rates" do
      it "renders list of all tax rates with pagination" do
        get tax_rates_path

        expect(controller_assigns(:tax_rates)).to include(active_tax_rate)
        expect(controller_assigns(:tax_rates)).to include(future_tax_rate)
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(response).to have_http_status(:ok)
      end

      it "renders list of active tax rates with pagination" do
        get active_tax_rates_path

        expect(controller_assigns(:tax_rates)).to include(active_tax_rate)
        expect(controller_assigns(:tax_rates)).to exclude(future_tax_rate)
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(response).to have_http_status(:ok)
      end

      it "renders list of future tax rates with pagination" do
        get future_tax_rates_path

        expect(controller_assigns(:tax_rates)).to include(future_tax_rate)
        expect(controller_assigns(:tax_rates)).to exclude(active_tax_rate)
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(response).to have_http_status(:ok)
      end

      it "renders list of expired tax rates with pagination" do
        travel_to(1.year.from_now) do
          get expired_tax_rates_path

          expect(controller_assigns(:tax_rates)).to include(future_tax_rate)
          expect(controller_assigns(:tax_rates)).to include(active_tax_rate)
          expect(controller_assigns(:pagination_metadata)).to be_present
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe "GET /tax-rates/new" do
      before { get new_tax_rate_path }

      include_examples "initializes a new instance", :tax_rate, TaxRate
    end

    describe "POST /tax-rates" do
      context "when provided attributes are valid" do
        it "creates the tax rate and redirects" do
          post tax_rates_path, params: {tax_rate: valid_attributes}, as: :turbo_stream

          expect(response).to redirect_to(tax_rates_path)
          expect(flash[:notice]).to eq("Tax rate was successfully created.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when provided attributes are invalid" do
        it "does not create the tax rate and renders errors" do
          post tax_rates_path, params: {tax_rate: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Tax rate could not be created.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_tax_rate_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /tax-rates/:id/edit" do
      it "renders tax rate edit page" do
        get edit_tax_rate_path(active_tax_rate)

        expect(controller_assigns(:tax_rate)).to eq(active_tax_rate)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /tax-rates/:id" do
      context "when provided attributes are valid" do
        it "updates the tax rate and redirects" do
          put tax_rate_path(active_tax_rate), params: {tax_rate: valid_attributes}, as: :turbo_stream

          expect(active_tax_rate.reload.tax_identifier_type).to eq("pan")
          expect(response).to redirect_to(tax_rates_path)
          expect(flash[:notice]).to eq("Tax rate was successfully updated.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when provided attributes are invalid" do
        it "does not update the tax rate and renders errors" do
          put tax_rate_path(active_tax_rate), params: {tax_rate: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Tax rate could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_tax_rate_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /tax-rates/:id" do
      context "when valid id" do
        it "deletes the tax rate and redirects" do
          delete tax_rate_path(active_tax_rate)

          expect(response).to redirect_to(tax_rates_path)
          expect(flash[:info]).to eq("Tax rate was successfully deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when delete fails" do
        it "does not delete the tax rate and redirects with an error message" do
          allow(TaxRates::DestroyService).to receive(:call) { ServiceResponse.error }

          delete tax_rate_path(active_tax_rate)

          expect(response).to redirect_to(tax_rates_path)
          expect(flash[:alert]).to eq("Tax rate could not be deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end
end
