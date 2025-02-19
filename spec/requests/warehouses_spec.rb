# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/warehouses_spec.rb

require "spec_helper"

RSpec.describe "Warehouses", type: :request do
  let!(:warehouse) { create(:warehouse, :active) }

  context "when user is not signed in" do
    describe "GET /warehouses" do
      subject { get warehouses_path }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /warehouses" do
      before { get warehouses_path }

      it "renders user list and returns :ok status" do
        expect(controller_assigns(:warehouses)).to be_present
        expect(controller_assigns(:pagination_data)).to be_present
        expect(controller_assigns(:warehouses).reload).to include(warehouse)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
