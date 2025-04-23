# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/preferences_spec.rb

require "spec_helper"

RSpec.describe "Preferences", type: :request do
  let(:valid_params) do
    {
      user: {
        user_preference_attributes: attributes_for(:user_preference)
      }
    }
  end
  let(:invalid_params) do
    {
      user: {
        user_preference_attributes: attributes_for(:user_preference, preferred_currency: "")
      }
    }
  end

  include_context "sign in as buyer"

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

      expect(controller_assigns(:current_user)).to eq(buyer)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<turbo-frame id=\"edit_preference_form_frame\" target=\"_top\">")
    end
  end

  describe "PUT|PATCH /preference" do
    context "when provided parameters are valid" do
      it "updates the preference and redirects" do
        put preference_path, params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(preference_path)
        expect(flash[:notice]).to eq("Your preferences were successfully updated.")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not update the preference and renders errors" do
        put preference_path, params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to eq("Your preferences could not be updated.")
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_preference_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
