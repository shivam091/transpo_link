# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/concerns/flash_messages_spec.rb

require "spec_helper"

RSpec.describe "FlashMessages", type: :request do
  let!(:controller_name) { "AnonymousController" }
  let!(:controller_class) do
    Class.new(ActionController::Base) do
      include FlashMessages

      def test_flash
        set_flash_message(
          params[:type].to_sym,
          params[:message_key],
          immediate: (params[:immediate] == "true"),
          scope: params[:scope],
          name: params[:name]
        )
        render plain: "OK"
      end
    end
  end

  before do
    stub_const(controller_name, controller_class)
    controller_class.define_singleton_method(:controller_name) { "anonymous" }
    controller_class.define_singleton_method(:controller_path) { "anonymous" }

    Rails.application.routes.draw do
      get "/anonymous", to: "anonymous#test_flash"
    end

    # Load translations for each test
    I18n.backend.store_translations(:en, {
      flashes: {
        anonymous: {
          test_flash: {
            success: "Operation was successful!",
            error: "Operation failed!",
            greeting: "Hello, %{name}! Welcome back.",
            failure: "Operation failed!"
          }
        }
      },
      custom: {
        scope: {
          error: "Something went wrong!"
        }
      }
    })
  end

  after do
    Rails.application.reload_routes!
    I18n.backend.reload! # Reset translations after each test to ensure isolation
  end

  context "when setting a flash message with default scope" do
    it "sets the correct flash message" do
      get "/anonymous", params: {type: "notice", message_key: "success"}

      expect(flash[:notice]).to eq("Operation was successful!")
    end
  end

  context "when setting a flash message with a custom scope" do
    it "sets the correct flash message under a custom scope" do
      get "/anonymous", params: {type: "alert", message_key: "error", scope: "custom.scope"}

      expect(flash[:alert]).to eq("Something went wrong!")
    end
  end

  context "when setting an immediate flash message (flash.now)" do
    it "sets the correct immediate flash message" do
      get "/anonymous", params: {type: "error", message_key: "failure", immediate: "true"}

      expect(flash.now[:error]).to eq("Operation failed!")
    end
  end

  context "when setting a flash message with interpolation options" do
    it "sets the correct message with interpolated values" do
      get "/anonymous", params: {type: "notice", message_key: "greeting", name: "John"}

      expect(flash[:notice]).to eq("Hello, John! Welcome back.")
    end
  end
end
