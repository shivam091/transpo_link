# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/legal_identifiers_spec.rb

require "spec_helper"

RSpec.describe "LegalIdentifiers", type: :request do
  include_context "sign in as buyer"

  let!(:unapproved_legal_identifier) { create(:legal_identifier, user: buyer) }

  let(:valid_params) do
    {
      legal_identifier: attributes_for(:legal_identifier,
        tax_identifier: "29AACCB3455A1Z9",
        user_id: buyer.id
      )
    }
  end
  let(:invalid_params) { {legal_identifier: attributes_for(:legal_identifier, tax_identifier: "")} }

  describe "GET /legal-identifiers" do
    let!(:approved_legal_identifier) { create(:legal_identifier, :approved, user: buyer, country: "US", tax_identifier_type: "ssn", tax_identifier: "514-14-8905") }
    let!(:rejected_legal_identifier) { create(:legal_identifier, :rejected, user: buyer, country: "AT", tax_identifier_type: "vat", tax_identifier: "ATU10223006") }

    it "renders list of all legal identifiers with pagination" do
      grant_permission!(buyer, :legal_identifiers, :view_all)

      get legal_identifiers_path

      expect(controller_assigns(:legal_identifiers)).to include(unapproved_legal_identifier)
      expect(controller_assigns(:legal_identifiers)).to include(approved_legal_identifier)
      expect(controller_assigns(:legal_identifiers)).to include(rejected_legal_identifier)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of unapproved legal identifiers with pagination" do
      grant_permission!(buyer, :legal_identifiers, :view_unapproved)

      get unapproved_legal_identifiers_path

      expect(controller_assigns(:legal_identifiers)).to include(unapproved_legal_identifier)
      expect(controller_assigns(:legal_identifiers)).to exclude(approved_legal_identifier)
      expect(controller_assigns(:legal_identifiers)).to exclude(rejected_legal_identifier)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of approved legal identifiers with pagination" do
      grant_permission!(buyer, :legal_identifiers, :view_approved)

      get approved_legal_identifiers_path

      expect(controller_assigns(:legal_identifiers)).to exclude(unapproved_legal_identifier)
      expect(controller_assigns(:legal_identifiers)).to include(approved_legal_identifier)
      expect(controller_assigns(:legal_identifiers)).to exclude(rejected_legal_identifier)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of rejected legal identifiers with pagination" do
      grant_permission!(buyer, :legal_identifiers, :view_rejected)

      get rejected_legal_identifiers_path

      expect(controller_assigns(:legal_identifiers)).to exclude(unapproved_legal_identifier)
      expect(controller_assigns(:legal_identifiers)).to exclude(approved_legal_identifier)
      expect(controller_assigns(:legal_identifiers)).to include(rejected_legal_identifier)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /legal-identifiers/new" do
    before do
      grant_permission!(buyer, :legal_identifiers, :create)
      get new_legal_identifier_path
    end

    include_examples "initializes a new instance", :legal_identifier, LegalIdentifier
  end

  describe "POST /legal-identifiers" do
    before { grant_permission!(buyer, :legal_identifiers, :create) }

    context "when provided parameters are valid" do
      it "creates the legal identifier and redirects" do
        post legal_identifiers_path, params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(legal_identifiers_path)
        expect(flash[:notice]).to eq("Legal identifier was successfully added.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not create the legal identifier and renders errors" do
        post legal_identifiers_path, params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Legal identifier could not be added.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"new_legal_identifier_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /legal-identifiers/:id/edit" do
    it "renders legal identifier edit page" do
      grant_permission!(buyer, :legal_identifiers, :update)

      get edit_legal_identifier_path(unapproved_legal_identifier)

      expect(controller_assigns(:legal_identifier)).to eq(unapproved_legal_identifier)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /legal-identifiers/:id" do
    before { grant_permission!(buyer, :legal_identifiers, :update) }

    context "when provided parameters are valid" do
      it "updates the legal identifier and redirects" do
        put legal_identifier_path(unapproved_legal_identifier), params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(legal_identifiers_path)
        expect(flash[:notice]).to eq("Legal identifier was successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not update the legal identifier and renders errors" do
        put legal_identifier_path(unapproved_legal_identifier), params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Legal identifier could not be updated.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_legal_identifier_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /legal-identifiers/:id" do
    before { grant_permission!(buyer, :legal_identifiers, :delete) }

    context "when deletion is successful" do
      it "deletes the legal identifier and redirects" do
        delete legal_identifier_path(unapproved_legal_identifier), as: :turbo_stream

        expect(response).to redirect_to(legal_identifiers_path)
        expect(flash[:info]).to eq("Legal identifier was successfully deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when deletion is unsuccessful" do
      it "does not delete the legal identifier and redirects with an error message" do
        allow(LegalIdentifiers::DestroyService).to receive(:call) { ServiceResponse.error }

        delete legal_identifier_path(unapproved_legal_identifier), as: :turbo_stream

        expect(response).to redirect_to(legal_identifiers_path)
        expect(flash[:alert]).to eq("Legal identifier could not be deleted.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "PATCH /legal-identifiers/:id/approve" do
    before { grant_permission!(buyer, :legal_identifiers, :approve) }

    context "when approval is successful" do
      it "approves the legal identifier and redirects" do
        patch approve_legal_identifier_path(unapproved_legal_identifier), as: :turbo_stream

        expect(response).to redirect_to(legal_identifiers_path)
        expect(flash[:info]).to eq("Legal identifier was successfully approved.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when approval is unsuccessful" do
      it "does not approve the legal identifier and redirects with an error message" do
        allow(LegalIdentifiers::ApproveService).to receive(:call) { ServiceResponse.error }

        patch approve_legal_identifier_path(unapproved_legal_identifier), as: :turbo_stream

        expect(response).to redirect_to(legal_identifiers_path)
        expect(flash[:alert]).to eq("Legal identifier could not be approved.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe "PATCH /legal-identifiers/:id/reject" do
    before { grant_permission!(buyer, :legal_identifiers, :reject) }

    context "when rejection is successful" do
      it "rejects the legal identifier and redirects" do
        patch reject_legal_identifier_path(unapproved_legal_identifier), as: :turbo_stream

        expect(response).to redirect_to(legal_identifiers_path)
        expect(flash[:info]).to eq("Legal identifier was successfully rejected.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when rejection is unsuccessful" do
      it "does not reject the legal identifier and redirects with an error message" do
        allow(LegalIdentifiers::RejectService).to receive(:call) { ServiceResponse.error }

        patch reject_legal_identifier_path(unapproved_legal_identifier), as: :turbo_stream

        expect(response).to redirect_to(legal_identifiers_path)
        expect(flash[:alert]).to eq("Legal identifier could not be rejected.")
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
