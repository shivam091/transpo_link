# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/dashboards_spec.rb

require "spec_helper"

RSpec.describe "Dashboards", type: :request do
  describe "GET /" do
    before { get root_path }

    it "returns :ok status" do
      expect(response).to have_http_status(:ok)
    end
  end
end
