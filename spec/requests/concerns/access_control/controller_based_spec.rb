# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/concerns/contextual_authorization_spec.rb

require "spec_helper"

RSpec.describe "ContextualAuthorization with controller-level and per-action rules", type: :request do
  let(:user) { create(:manager) }

  with_mock_controller(ActionController::Base, name: "ControllerBasedAuthorizations") do
    include ContextualAuthorization

    # Controller-wide rule: all actions require this unless overridden
    requires_authorization "orders", "view"
    # Per-action override
    requires_authorization_for :new, "orders", "create"

    def index
      render plain: "Authorized"
    end

    def new
      render plain: "Authorized"
    end

    private

    def current_user
      User.find(session[:user_id])
    end
  end

  before do
    Rails.application.routes.draw do
      get "/controller_based_global", to: "controller_based_authorizations#index"
      get "/controller_based_per_action", to: "controller_based_authorizations#new"
    end

    allow_any_instance_of(Warden::Proxy).to receive(:authenticate!) { user }
    allow_any_instance_of(ControllerBasedAuthorizationsController).to receive(:current_user) { user }
  end

  after { Rails.application.reload_routes! }

  describe "authorization via controller-wide rule" do
    context "when user is authorized" do
      before do
        allow_any_instance_of(Ability).to receive(:authorize!).with("orders", "view") { true }
      end

      it "grants access to index action" do
        get "/controller_based_global"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("Authorized")
      end
    end

    context "when user is not authorized" do
      before do
        allow_any_instance_of(Ability).to receive(:authorize!).with("orders", "view")
          .and_raise(AccessDeniedError.new("orders", "view"))
      end

      it "raises AccessDeniedError for index action" do
        expect {
          get "/controller_based_global"
        }.to raise_error(AccessDeniedError, "Access denied to module: orders, action: view")
      end
    end
  end

  describe "authorization via per-action override" do
    context "when user is authorized for the specific action" do
      before do
        allow_any_instance_of(Ability).to receive(:authorize!).with("orders", "create") { true }
      end

      it "grants access to new action" do
        get "/controller_based_per_action"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("Authorized")
      end
    end

    context "when user is not authorized for the specific action" do
      before do
        allow_any_instance_of(Ability).to receive(:authorize!).with("orders", "create")
          .and_raise(AccessDeniedError.new("orders", "create"))
      end

      it "raises AccessDeniedError for new action" do
        expect {
          get "/controller_based_per_action"
        }.to raise_error(AccessDeniedError, "Access denied to module: orders, action: create")
      end
    end
  end
end
