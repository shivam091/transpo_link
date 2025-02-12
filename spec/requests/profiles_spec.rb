# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/profiles_spec.rb

require "spec_helper"

RSpec.describe "Profiles", type: :request do
  context "when user is not logged in" do
    describe "GET /profile" do
      subject { get profile_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /profile/edit" do
      subject { get edit_profile_path }

      it { is_expected.to require_sign_in }
    end

    describe "PUT|PATCH /profile" do
      subject { put profile_path }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is logged in" do
    include_context "sign in as admin"

    describe "GET /profile" do
      before { get profile_path }

      it "renders profile page" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("<div class='widget-help'>Edit your profile details viz., first name, last name, address, etc.</div>")
      end
    end

    describe "GET /profile/edit" do
      before { get edit_profile_path }

      it "renders profile edit page" do
        expect(admin).to eq(controller_assigns(:current_user))
        expect(response.body).to include("<turbo-frame id=\"profile_form\" target=\"_top\">")
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PUT|PATCH /profile" do
      context "with valid attributes" do
        it "updates the profile" do
          put profile_path, params: {
            user: {user_detail_attributes: {first_name: "John"}}
          }, as: :turbo_stream

          expect(admin.first_name).to eq("John")
          expect(flash[:notice]).to eq("Your profile was successfully updated.")
          expect(response).to redirect_to(profile_path)
          expect(response).to have_http_status(:see_other)
        end
      end

      context "with invalid attributes" do
        it "does not update the profile" do
          put profile_path, params: {
            user: {user_detail_attributes: {first_name: ""}}
          }, as: :turbo_stream

          admin.reload

          expect(admin.first_name).to eq("TranspoLink")
          expect(flash[:alert]).to eq("Your profile could not be updated.")
          expect(response.media_type).to eq(Mime[:turbo_stream])
          expect(response.body).to include("<turbo-stream action=\"update\" target=\"profile_form\">")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
