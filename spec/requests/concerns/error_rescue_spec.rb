# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/concerns/error_rescue_spec.rb

require "spec_helper"

RSpec.describe "ErrorRescue", type: :request do
  with_mock_controller(ActionController::Base, name: "Anonymous") do
    include ErrorRescue

    def trigger_not_found
      raise ActiveRecord::RecordNotFound
    end

    def trigger_routing_error
      raise ActionController::RoutingError, "Not Found"
    end

    def trigger_internal_error
      raise StandardError, "Unexpected"
    end

    def trigger_application_error
      raise ApplicationError
    end

    def trigger_invalid_token
      raise ActionController::InvalidAuthenticityToken
    end
  end

  before do
    Rails.application.routes.draw do
      get "/test_not_found", to: "anonymous#trigger_not_found"
      get "/test_routing_error", to: "anonymous#trigger_routing_error"
      get "/test_internal_error", to: "anonymous#trigger_internal_error"
      get "/test_application_error", to: "anonymous#trigger_application_error"
      get "/test_invalid_token", to: "anonymous#trigger_invalid_token"

      devise_for :users # required if you use `new_user_session_path`

      root to: "anonymous#trigger_not_found"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  context "when an ActiveRecord::RecordNotFound error is raised" do
    it "renders the 404 not found template" do
      get "/test_not_found"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Oops! Page not found")
    end
  end

  context "when an ActionController::RoutingError is raised" do
    it "renders the 404 not found template" do
      get "/test_routing_error"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Oops! Page not found")
    end
  end

  context "when a generic StandardError is raised" do
    it "renders the 500 internal server error template" do
      get "/test_internal_error"

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include("Internal Server Error")
    end
  end

  context "when an ApplicationError is raised" do
    it "redirects back with flash alert" do
      get "/test_application_error"

      expect(response).to redirect_to("/")
      expect(flash[:alert]).to eq("Failed to complete the request due to unexpected error.")
    end
  end

  context "when an InvalidAuthenticityToken is raised" do
    let(:user) { create(:manager) }

    before { sign_in user }

    it "signs out the user and redirects to login page" do
      get "/test_invalid_token"

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
