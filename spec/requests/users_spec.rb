# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/users_spec.rb

require "spec_helper"

RSpec.describe "Users", type: :request do
  let!(:active_user) { create(:admin, :confirmed, :active) }
  let!(:inactive_user) { create(:admin) }
  let!(:suspended_user) { create(:admin, :active, :suspended) }

  include_context "sign in as admin"

  describe "GET /users" do
    it "renders list of all users with pagination" do
      grant_permission!(admin, "users", "view_all")

      get users_path

      expect(controller_assigns(:users)).to include(active_user)
      expect(controller_assigns(:users)).to include(inactive_user)
      expect(controller_assigns(:users)).to include(suspended_user)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of active users with pagination" do
      grant_permission!(admin, "users", "view_active")

      get active_users_path

      expect(controller_assigns(:users)).to include(active_user)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of inactive users with pagination" do
      grant_permission!(admin, "users", "view_inactive")

      get inactive_users_path

      expect(controller_assigns(:users)).to include(inactive_user)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end

    it "renders list of suspended users with pagination" do
      grant_permission!(admin, "users", "view_suspended")

      get suspended_users_path

      expect(controller_assigns(:users)).to include(suspended_user)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/:id" do
    it "renders user details page" do
      grant_permission!(admin, "users", "view")

      get user_path(active_user)

      expect(controller_assigns(:user)).to eq(active_user)
      expect(response).to have_http_status(:ok)
    end
  end
end
