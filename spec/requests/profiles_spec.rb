# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/profiles_spec.rb

require "spec_helper"

RSpec.describe "Profiles", type: :request do
  context "when user is not logged in" do
    describe "GET /profile" do
      subject { get profile_path }

      it { is_expected.to require_login }
    end

    describe "GET /profile/edit" do
      subject { get edit_profile_path }

      it { is_expected.to require_login }
    end

    describe "PUT|PATCH /profile" do
      subject { put profile_path }

      it { is_expected.to require_login }
    end
  end

  context "when user is logged in" do
    include_context "login as admin"

    describe "GET /profile" do
      before { get profile_path }

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /profile/edit" do
      before { get edit_profile_path }

      it "makes logged in user's profile available for edit" do
        expect(admin).to eq(controller_assigns(:current_user))
      end

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /profile" do
      context "with valid attributes" do
        before do
          put profile_path, params: {
            user: {user_detail_attributes: {first_name: "John"}}
          }, as: :turbo_stream
        end

        it "updates the profile" do
          expect(admin.first_name).to eq("John")
        end

        it "redirects to profile page and returns :see_other status" do
          expect(flash[:notice]).to eq("Your profile was successfully updated.")
          expect(response).to redirect_to(profile_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "with invalid attributes" do
        before do
          put profile_path, params: {
            user: {user_detail_attributes: {first_name: ""}}
          }, as: :turbo_stream
        end

        it "does not update the profile" do
          admin.reload
          expect(admin.first_name).to eq("TranspoLink")
        end

        it "updates turbo frame 'profile_form' and returns :unprocessable_entity status" do
          expect(flash[:alert]).to eq("Your profile could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"profile_form\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
