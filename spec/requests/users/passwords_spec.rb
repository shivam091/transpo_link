# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/users/passwords_spec.rb

require "spec_helper"

RSpec.describe "Users::Passwords", type: :request do
  let(:user) { create(:admin) }
  let(:dummy_password) { Rails.application.credentials.config[:TEST_PASSWORD] }

  describe "GET /users/password/new" do
    it "renders the password reset request page" do
      get new_user_password_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<h4 class='fw-bold mb-4 fw-normal'>Password assistance</h4>")
    end
  end

  describe "POST /users/password" do
    context "when the user has not recently requested a password reset" do
      it "sends password reset instructions" do
        expect {
          post user_password_path, params: {user: {email: user.email}}
        }.to change { ActionMailer::Base.deliveries.count }.by(0)

        expect(response).to redirect_to(new_user_session_path)
        expect(response).to have_http_status(:see_other)
        follow_redirect!
        expect(flash[:notice]).to eq("You will receive an email with instructions on how to reset your password in a few minutes.")
      end
    end

    context "when the user has recently requested a password reset" do
      before do
        allow_any_instance_of(User).to receive(:recently_sent_password_reset_instructions?) { true }
      end

      it "throttles the password reset request" do
        expect {
          post user_password_path, params: {user: {email: user.email}}
        }.not_to change { ActionMailer::Base.deliveries.count }

        expect(response).to redirect_to(new_user_session_path)
        expect(response).to have_http_status(:found)
        follow_redirect!
        expect(flash[:alert]).to eq("Password reset instructions can be sent only once in 2 minutes. Please wait a few minutes before you try again.")
      end
    end

    context "when the email does not exist" do
      it "does not send password reset instructions but responds as if it did (for security)" do
        expect {
          post user_password_path, params: {user: {email: "nonexistent@example.com"}}
        }.not_to change { ActionMailer::Base.deliveries.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Email address not found")
      end
    end
  end

  describe "GET /users/password/edit" do
    let(:reset_token) { user.send_reset_password_instructions }

    it "renders the password change page" do
      get edit_user_password_path, params: {reset_password_token: reset_token}

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<h4 class='fw-bold mb-4 fw-normal'>Create new password</h4>")
    end
  end

  describe "PUT|PATCH /users/password" do
    let(:reset_token) { user.send_reset_password_instructions }

    context "with valid token and matching passwords" do
      it "resets the password successfully" do
        put user_password_path, params: {
          user: {
            reset_password_token: reset_token,
            password: dummy_password,
            password_confirmation: dummy_password
          }
        }

        expect(response).to redirect_to(new_user_session_path)
        expect(response).to have_http_status(:see_other)
        follow_redirect!
        expect(response.body).to include("Your password has been changed successfully.")
      end
    end

    context "with invalid token" do
      it "does not reset the password" do
        put user_password_path, params: {
          user: {
            reset_password_token: "invalidtoken",
            password: dummy_password,
            password_confirmation: dummy_password
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Reset password token is invalid")
      end
    end

    context "with mismatched password and confirmation" do
      it "does not reset the password" do
        put user_password_path, params: {
          user: {
            reset_password_token: reset_token,
            password: dummy_password,
            password_confirmation: "MismatchPassword123"
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Password confirmation doesn't match Password")
      end
    end
  end
end
