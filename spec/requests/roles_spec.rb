# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/roles_spec.rb

require "spec_helper"

RSpec.describe "Roles", type: :request do
  let!(:role) { create(:manager_role) }

  let(:valid_params) { {role: attributes_for(:role, name: "New name")} }
  let(:invalid_params) { {role: attributes_for(:role, name: "")} }

  include_context "sign in as admin"

  describe "GET /roles" do
    it "renders list of all roles" do
      get roles_path

      expect(controller_assigns(:roles)).to include(role)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /roles/:id/edit" do
    it "renders role edit page" do
      get edit_role_path(role)

      expect(controller_assigns(:role)).to eq(role)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /roles/:id" do
    context "when provided parameters are valid" do
      it "updates the role and redirects" do
        expect {
          put role_path(role), params: valid_params, as: :turbo_stream
        }.to change { role.reload.name }.to("New name")

        expect(response).to redirect_to(roles_path)
        expect(flash[:notice]).to eq("Role was successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not update the role and renders errors" do
        expect {
          put role_path(role), params: invalid_params, as: :turbo_stream
        }.to not_change { role.reload.name }

        expect(flash[:alert]).to eq("Role could not be updated.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_role_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /roles/:id" do
    it "renders role details page" do
      get role_path(role)

      expect(controller_assigns(:role)).to eq(role)
      expect(response).to have_http_status(:ok)
    end
  end
end
