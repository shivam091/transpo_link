# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/preferences_spec.rb

require "spec_helper"

RSpec.describe "Preferences", type: :request do
  context "when user is not logged in" do
    describe "GET /preference" do
      subject { get preference_path }

      it { is_expected.to require_login }
    end

    describe "GET /preference/edit" do
      subject { get edit_preference_path }

      it { is_expected.to require_login }
    end

    describe "PUT|PATCH /preference" do
      subject { put preference_path }

      it { is_expected.to require_login }
    end
  end

  context "when user is logged in" do
    include_context "login as admin"

    describe "GET /preference" do
      it "renders preference page" do
        get preference_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("<div class='widget-help'>Edit your preferences viz. color scheme, time zone, language, etc.</div>")
      end
    end

    describe "GET /preference/edit" do
      it "renders preference edit page" do
        get edit_preference_path

        expect(admin).to eq(controller_assigns(:current_user))
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("<turbo-frame id=\"preference_form\" target=\"_top\">")
      end
    end

    describe "PUT|PATCH /preference" do
      context "with valid attributes" do
        it "updates the preference" do
          put preference_path, params: {
            user: {user_preference_attributes: {preferred_currency: "GBP"}}
          }, as: :turbo_stream

          expect(admin.preferred_currency).to eq("GBP")
          expect(flash[:notice]).to eq("Your preferences were successfully updated.")
          expect(response).to redirect_to(preference_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "with invalid attributes" do
        it "does not update the preference" do
          put preference_path, params: {
            user: {user_preference_attributes: {preferred_currency: ""}}
          }, as: :turbo_stream

          admin.reload

          expect(admin.preferred_currency).to eq("INR")
          expect(flash[:alert]).to eq("Your preferences could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"preference_form\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
