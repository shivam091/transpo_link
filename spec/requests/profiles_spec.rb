# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/profiles_spec.rb

require "spec_helper"

RSpec.describe "Profiles", type: :request do
  let(:valid_params) do
    {
      user: {
        user_detail_attributes: attributes_for(:user_detail,
          first_name: "John"
        )
      }
    }
  end
  let(:invalid_params) do
    {
      user: {
        user_detail_attributes: attributes_for(:user_detail,
          first_name: ""
        )
      }
    }
  end

  include_context "sign in as admin"

  describe "GET /profile" do
    it "renders profile page" do
      get profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/Edit your personal details viz., first name, last name, address, and more to ensure your profile reflects the latest information./)
    end
  end

  describe "GET /profile/edit" do
    it "renders profile edit page" do
      get edit_profile_path

      expect(admin).to eq(controller_assigns(:current_user))
      expect(response.body).to include("<turbo-frame id=\"edit_profile_form_frame\" target=\"_top\">")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT|PATCH /profile" do
    context "when provided parameters are valid" do
      it "updates the profile and redirects" do
        expect {
          put profile_path, params: valid_params, as: :turbo_stream
        }.to change { admin.reload.first_name }.to("John")

        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to eq("Your profile was successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not update the profile and renders errors" do
        expect {
          put profile_path, params: invalid_params, as: :turbo_stream
        }.to not_change { admin.reload.first_name }

        expect(flash[:alert]).to eq("Your profile could not be updated.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_profile_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
