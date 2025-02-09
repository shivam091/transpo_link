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
      before { get preference_path }

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /preference/edit" do
      before { get edit_preference_path }

      it "makes logged in user's preferences available for edit" do
        expect(admin).to eq(controller_assigns(:current_user))
      end

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /preference" do
      context "with valid attributes" do
        before do
          put preference_path, params: {
            user: {user_preference_attributes: {preferred_currency: "GBP"}}
          }, as: :turbo_stream
        end

        it "updates the preference" do
          expect(admin.preferred_currency).to eq("GBP")
        end

        it "redirects to preference page and returns :see_other status" do
          expect(flash[:notice]).to eq("Your preferences were successfully updated.")
          expect(response).to redirect_to(preference_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "with invalid attributes" do
        before do
          put preference_path, params: {
            user: {user_preference_attributes: {preferred_currency: ""}}
          }, as: :turbo_stream
        end

        it "does not update the preference" do
          admin.reload
          expect(admin.preferred_currency).to eq("INR")
        end

        it "updates turbo frame 'preference_form' and returns :unprocessable_entity status" do
          expect(flash[:alert]).to eq("Your preferences could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"preference_form\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
