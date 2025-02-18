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
      before { get users_path }

      it "renders user list and returns :ok status" do
        expect(controller_assigns(:users).reload).to include(admin)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /users/:id" do
      before { get user_path(admin) }

      it "returns :ok status" do
        expect(controller_assigns(:user).reload).to eq(admin)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
