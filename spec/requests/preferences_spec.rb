# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/preferences_spec.rb

require "spec_helper"

RSpec.describe "Preferences", type: :request do
  let(:valid_attributes) { {preferred_currency: "GBP"} }
  let(:invalid_attributes) { {preferred_currency: ""} }

  include_context "sign in as admin"

  describe "GET /preference" do
    it "renders preference page" do
      get preference_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/Customize your preferences, including color scheme, time zone, language, and other settings to suit your personal experience./)
    end
  end

  describe "GET /preference/edit" do
    it "renders preference edit page" do
      get edit_preference_path

      expect(admin).to eq(controller_assigns(:current_user))
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<turbo-frame id=\"edit_preference_form_frame\" target=\"_top\">")
    end
  end

  describe "PUT|PATCH /preference" do
    context "when provided attributes are valid" do
      it "updates the preference and redirects" do
        expect {
          put preference_path, params: {user: {user_preference_attributes: valid_attributes}}, as: :turbo_stream
        }.to change { admin.reload.preferred_currency }.to("GBP")

        expect(response).to redirect_to(preference_path)
        expect(flash[:notice]).to eq("Your preferences were successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided attributes are invalid" do
      it "does not update the preference and renders errors" do
        expect {
          put preference_path, params: {user: {user_preference_attributes: invalid_attributes}}, as: :turbo_stream
        }.to not_change { admin.reload.preferred_currency }

        expect(flash[:alert]).to eq("Your preferences could not be updated.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_preference_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
