# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/request_logs_spec.rb

require "spec_helper"

RSpec.describe "RequestLogs", type: :request do
  let!(:request_log) { create(:request_log) }

  context "when user is not signed in" do
    describe "GET /request-logs" do
      subject { get request_logs_path }

      it { is_expected.to require_sign_in }
    end

    describe "GET /request-logs/:id" do
      subject { get request_log_path(request_log) }

      it { is_expected.to require_sign_in }
    end
  end

  context "when user is signed in" do
    include_context "sign in as admin"

    describe "GET /request-logs" do
      before { get request_logs_path }

      it "renders request logs list and returns :ok status" do
        expect(controller_assigns(:request_logs)).to be_present
        expect(controller_assigns(:pagination_metadata)).to be_present
        expect(controller_assigns(:request_logs).reload).to include(request_log)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /request-logs/:id" do
      before { get request_log_path(request_log) }

      it "returns :ok status" do
        expect(controller_assigns(:request_log).reload).to eq(request_log)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
