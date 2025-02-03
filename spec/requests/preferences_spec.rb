# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/preferences_spec.rb

require "spec_helper"

RSpec.describe "Preferences", type: :request do
  context "when user is not logged in" do
    describe "GET /preference" do
      subject { get preference_path }

      it { is_expected.to require_login }
    end
  end

  context "when user is logged in" do
    include_context "login as admin"

    describe "GET /preference" do
      before { get preference_path }

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
