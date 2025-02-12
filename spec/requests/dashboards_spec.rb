# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/dashboards_spec.rb

require "spec_helper"

RSpec.describe "Dashboards", type: :request do

  context "when user is not logged in" do
    describe "GET /" do
      subject { get root_path }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is logged in" do
    include_context "sign in as admin"

    describe "GET /" do
      before { get root_path }

      it "returns :ok status" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
