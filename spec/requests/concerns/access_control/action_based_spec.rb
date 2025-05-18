# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/concerns/access_control/action_based_spec.rb

require "spec_helper"

RSpec.describe "ContextualAuthorization with explicit action-level check", type: :request do
  let(:user) { create(:manager) }

  with_mock_controller(ActionController::Base, name: "ActionBasedAuthorizations") do
    include ContextualAuthorization

    def index
      require_authorization "orders", "view"
      render plain: "Authorized"
    end

    private

    def current_user
      User.find(session[:user_id])
    end
  end

  before do
    Rails.application.routes.draw do
      get "/action_based", to: "action_based_authorizations#index"
    end

    allow_any_instance_of(Warden::Proxy).to receive(:authenticate!) { user }
    allow_any_instance_of(ActionBasedAuthorizationsController).to receive(:current_user) { user }
  end

  after { Rails.application.reload_routes! }

  describe "manual authorization using `require_authorization`" do
    context "when user is authorized for the action" do
      before do
        allow_any_instance_of(Ability).to receive(:authorize!).with("orders", "view") { true }
      end

      it "grants access" do
        get "/action_based"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("Authorized")
      end
    end

    context "when user is not authorized for the action" do
      before do
        allow_any_instance_of(Ability).to receive(:authorize!).with("orders", "view")
          .and_raise(AccessDeniedError.new("orders", "view"))
      end

      it "raises AccessDeniedError" do
        expect {
          get "/action_based"
        }.to raise_error(AccessDeniedError, "Access denied to module: orders, action: view")
      end
    end
  end
end
