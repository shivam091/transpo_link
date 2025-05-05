# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/locales_spec.rb

require "spec_helper"

RSpec.describe "Locales", type: :request do
  let(:valid_params) do
    {
      user: {
        preference_attributes: attributes_for(:user_preference,
          preferred_locale: "es"
        )
      }
    }
  end
  let(:invalid_params) do
    {
      user: {
        preference_attributes: attributes_for(:user_preference,
          preferred_locale: ""
        )
      }
    }
  end

  include_context "sign in as manager"

  describe "GET /locale/edit" do
    it "renders locale edit page" do
      get edit_locale_path, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<turbo-frame id=\"edit_locale_form_frame\" target=\"_top\">")
      expect(response.body).to include("modal")
      expect(response.body).to include("name=\"user[preference_attributes][preferred_locale]\"")
    end
  end

  describe "PUT|PATCH /locale" do
    context "when provided parameters are valid" do
      it "updates the locale and redirects" do
        put locale_path, params: valid_params, as: :turbo_stream

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to be_present
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when provided parameters are invalid" do
      it "does not update the locale and renders errors" do
        put locale_path, params: invalid_params, as: :turbo_stream

        expect(flash[:alert]).to be_present
        expect(response.media_type).to eq(Mime[:turbo_stream])
        expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_locale_form_frame\">")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
