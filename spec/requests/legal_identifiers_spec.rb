# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/legal_identifiers_spec.rb

require "spec_helper"

RSpec.describe "LegalIdentifiers", type: :request do
  let!(:buyer) { create(:buyer) }
  let!(:legal_identifier) { create(:legal_identifier, user: buyer) }

  let(:valid_attributes) { attributes_for(:legal_identifier, tax_identifier: "29AACCB3455A1Z9").merge(user_id: buyer.id) }
  let(:invalid_attributes) { attributes_for(:legal_identifier, tax_identifier: "") }

  context "when user is not signed in" do
    describe "GET /legal-identifiers" do
      subject { get legal_identifiers_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /legal-identifiers/new" do
      subject { get new_legal_identifier_path }

      it { is_expected.to require_sign_in }
    end

    describe "POST /legal-identifiers" do
      subject { post legal_identifiers_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /legal-identifiers/:id/edit" do
      subject { get edit_legal_identifier_path(legal_identifier) }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /legal-identifiers/:id" do
      subject { put legal_identifier_path(legal_identifier) }

      it { is_expected.to require_sign_in }
    end

    describe "DELETE /legal-identifiers/:id" do
      subject { delete legal_identifier_path(legal_identifier) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as buyer"

    describe "GET /legal-identifiers" do
      it "renders list of all legal identifiers with pagination" do
        get legal_identifiers_path

        expect(controller_assigns(:legal_identifiers)).to include(legal_identifier)
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /legal-identifiers/new" do
      before { get new_legal_identifier_path }

      include_examples "initializes a new instance", :legal_identifier, LegalIdentifier
    end

    describe "POST /legal-identifiers" do
      context "when provided attributes are valid" do
        it "creates the legal identifier and redirects" do
          post legal_identifiers_path, params: {legal_identifier: valid_attributes}, as: :turbo_stream

          expect(response).to redirect_to(legal_identifiers_path)
          expect(flash[:notice]).to eq("Legal identifier was successfully added.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when provided attributes are invalid" do
        it "does not create the legal identifier and renders errors" do
          post legal_identifiers_path, params: {legal_identifier: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Legal identifier could not be added.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_legal_identifier_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "GET /legal-identifiers/:id/edit" do
      it "renders legal identifier edit page" do
        get edit_legal_identifier_path(legal_identifier)

        expect(controller_assigns(:legal_identifier)).to eq(legal_identifier)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /legal-identifiers/:id" do
      context "when provided attributes are valid" do
        it "updates the legal identifier and redirects" do
          put legal_identifier_path(legal_identifier), params: {legal_identifier: valid_attributes}, as: :turbo_stream

          expect(legal_identifier.reload.tax_identifier).to eq("29AACCB3455A1Z9")
          expect(response).to redirect_to(legal_identifiers_path)
          expect(flash[:notice]).to eq("Legal identifier was successfully updated.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when provided attributes are invalid" do
        it "does not update the legal identifier and renders errors" do
          put legal_identifier_path(legal_identifier), params: {legal_identifier: invalid_attributes}, as: :turbo_stream

          expect(flash[:alert]).to eq("Legal identifier could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_legal_identifier_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /legal-identifiers/:id" do
      context "when valid id" do
        it "deletes the legal identifier and redirects" do
          delete legal_identifier_path(legal_identifier)

          expect(response).to redirect_to(legal_identifiers_path)
          expect(flash[:info]).to eq("Legal identifier was successfully deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end

      context "when delete fails" do
        it "does not delete the legal identifier and redirects with an error message" do
          allow(LegalIdentifiers::DestroyService).to receive(:call) { ServiceResponse.error }

          delete legal_identifier_path(legal_identifier)

          expect(response).to redirect_to(legal_identifiers_path)
          expect(flash[:alert]).to eq("Legal identifier could not be deleted.")
          expect(response).to have_http_status(:see_other)
        end
      end
    end
  end
end
