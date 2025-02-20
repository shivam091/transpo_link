# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/locales_spec.rb

require "spec_helper"

RSpec.describe "Locales", type: :request do
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
      before { get edit_locale_path }

      it "renders locale edit modal" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("<turbo-frame id=\"edit_locale_form\" target=\"_top\">")
        expect(response.body).to include("modal")
        expect(response.body).to include("name=\"user[user_preference_attributes][preferred_locale]\"")
      end
    end

    describe "PUT|PATCH /locale" do
      context "when valid attributes" do
        it "updates the language" do
          put locale_path, params: {
            user: {user_preference_attributes: {preferred_locale: "es"}}
          }, headers: {"HTTP_REFERER" => root_path}, as: :turbo_stream

          expect(admin.reload.preferred_locale).to eq("es")
          expect(response).not_to redirect_to(preference_path)
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to be_present
          expect(response).to have_http_status(:found)
        end
      end

      context "when invalid attributes" do
        it "does not update the language" do
          put locale_path, params: {
            user: {user_preference_attributes: {preferred_locale: ""}}
          }, as: :turbo_stream

          expect(admin.reload.preferred_locale).to eq("en")
          expect(flash[:alert]).to be_present
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"edit_locale_form\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
