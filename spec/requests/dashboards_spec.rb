# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/dashboards_spec.rb

require "spec_helper"

RSpec.describe "Dashboards", type: :request do
  include_context "sign in as admin"

  describe "GET /" do
    it "renders dashboard page" do
      grant_permission!(admin, "dashboards", "view")

      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
