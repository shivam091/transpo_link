# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/application_spec.rb

require "spec_helper"

RSpec.describe "Application", type: :request do
  describe "#check_if_banned" do
    context "when user is signed in" do
      include_context "sign in as buyer"

      before { get root_path }

      context "when user is not banned" do
        it "allows the user to proceed" do
          expect(response).to have_http_status(:ok)
        end
      end

      context "when user is banned" do
        it "signs out the user and redirects to login with an alert message" do
          buyer.toggle!(:is_banned)
          buyer.reload
          
          get root_path

          expect(flash[:alert]).to eq("Your account is suspended. If you believe your account was suspended by mistake, please communicate with administrator for further assistance.")
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    context "when user is not signed in" do
      it "does not trigger the check" do
        get new_user_session_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
