# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/locales_spec.rb

require "spec_helper"

RSpec.describe "Locales", type: :request do
  let!(:valid_attributes) { {preferred_locale: "es"} }
  let!(:invalid_attributes) { {preferred_locale: ""} }

  context "when user is not signed in" do
    describe "GET /locale/edit" do
      subject { get edit_locale_path }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /locale" do
      subject { put locale_path }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /locale/edit" do
      it "renders locale edit page" do
        get edit_locale_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("<turbo-frame id=\"edit_locale_form_frame\" target=\"_top\">")
        expect(response.body).to include("modal")
        expect(response.body).to include("name=\"user[user_preference_attributes][preferred_locale]\"")
      end
    end

    describe "PUT|PATCH /locale" do
      context "when provided attributes are valid" do
        it "updates the locale and redirects" do
          put locale_path, params: {
            user: {user_preference_attributes: valid_attributes}
          }, headers: {"HTTP_REFERER" => root_path}, as: :turbo_stream

          expect(admin.reload.preferred_locale).to eq("es")
          expect(response).to redirect_to(root_path)
          expect(response).not_to redirect_to(preference_path)
          expect(flash[:notice]).to be_present
          expect(response).to have_http_status(:found)
        end
      end

      context "when provided attributes are invalid" do
        it "does not update the locale and renders errors" do
          put locale_path, params: {user: {user_preference_attributes: invalid_attributes}}, as: :turbo_stream

          expect(admin.reload.preferred_locale).to eq("en")
          expect(flash[:alert]).to be_present
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_locale_form_frame\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
