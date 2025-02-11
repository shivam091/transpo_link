# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/users/sessions_spec.rb

require "spec_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:admin, :active, :confirmed) }
  let(:dummy_password) { Rails.application.credentials.config[:TEST_PASSWORD] }

  describe "GET /users/sign-in" do
    it "renders the sign in page" do
      get new_user_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<h4 class='fw-bold mb-4 fw-normal'>Welcome! Sign in to your account</h4>")
    end
  end

  describe "POST /users/sign-in" do
    context "when valid credentials" do
      it "signs in the user and redirects to the root path" do
        post user_session_path, params: {user: {email: user.email, password: dummy_password}}

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(flash[:notice]).to eq("Hi #{user.full_name}, welcome to TranspoLink!")
        expect(response).to have_http_status(:ok)
      end

      it "clears reset_password_token if present" do
        user.update!(reset_password_token: "dummy_token", reset_password_sent_at: 1.hour.ago)

        post user_session_path, params: {user: {email: user.email, password: dummy_password}}

        user.reload
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
        expect(flash[:notice]).to eq("Hi #{user.full_name}, welcome to TranspoLink!")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when invalid credentials" do
      it "does not sign in the user and re-renders the sign-in page" do
        post user_session_path, params: {user: {email: user.email, password: "WrongPassword"}}

        expect(flash[:alert]).to eq("It looks like your email and password combination isn't quite right, please try again.")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when email is missing" do
      it "redirects back with an alert for missing email" do
        post user_session_path, params: {user: {email: "", password: "Password123"}}

        expect(response).to redirect_to(new_user_session_path)
        follow_redirect!
        expect(flash[:alert]).to eq("Please enter your email and password")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when password is missing" do
      it "redirects back with an alert for missing password" do
        post user_session_path, params: {user: { email: user.email, password: ""}}

        expect(response).to redirect_to(new_user_session_path)
        follow_redirect!
        expect(flash[:alert]).to eq("Please enter your email and password")
        expect(response).to have_http_status(:ok)
      end
    end

    context "when inexistant email" do
      it "redirects back with an alert for missing password" do
        post user_session_path, params: {user: { email: "test@example.com", password: "Dummy_password"}}

        expect(flash[:alert]).to eq("We could not find an account with that email address.")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when user is suspended" do
      it "redirects back with an alert for suspend" do
        user.toggle!(:is_banned)

        post user_session_path, params: {user: { email: user.email, password: dummy_password}}

        expect(response).to redirect_to(new_user_session_path)
        follow_redirect!
        expect(flash[:alert]).to eq("Your account is suspended. If you believe your account was suspended by mistake, please communicate with administrator for further assistance.")
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE /users/sign-out" do
    before { sign_in(user) }

    it "signs out the user and redirects to sign-in page" do
      delete destroy_user_session_path

      expect(response).to redirect_to(new_user_session_path)
      follow_redirect!
      expect(flash[:notice]).to eq("You are successfully signed out.")
      expect(response).to have_http_status(:ok)
    end
  end
end
