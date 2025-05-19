# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/request_logs_spec.rb

require "spec_helper"

RSpec.describe "RequestLogs", type: :request do
  let!(:request_log) { create(:request_log) }

  include_context "sign in as admin"

  describe "GET /request-logs" do
    it "renders list of all request logs with pagination" do
      grant_permission!(admin, :request_logs, :view_all)

      get request_logs_path

      expect(controller_assigns(:request_logs)).to include(request_log)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /request-logs/:id" do
    it "renders request log details page" do
      grant_permission!(admin, :request_logs, :view)

      get request_log_path(request_log)

      expect(controller_assigns(:request_log)).to eq(request_log)
      expect(response).to have_http_status(:ok)
    end
  end
end
