# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/users_spec.rb

require "spec_helper"

RSpec.describe "Users", type: :request do
  let!(:admin) { create(:admin, :confirmed, :active) }

  context "when user is not signed in" do
    describe "GET /users" do
      subject { get users_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /users/:id" do
      subject { get user_path(admin) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /users" do
      it "renders list of all users with pagination" do
        get users_path

        expect(controller_assigns(:users)).to include(admin)
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /users/:id" do
      it "renders user details page" do
        get user_path(admin)

        expect(controller_assigns(:user)).to eq(admin)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
