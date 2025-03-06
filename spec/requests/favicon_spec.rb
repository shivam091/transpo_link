# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/favicon_spec.rb

require "spec_helper"

RSpec.describe "Favicon", type: :request do
  let(:favicon_url) { ActionController::Base.helpers.asset_url(TranspoLink::Favicon.main) }

  describe "GET /favicon.png" do
    it "redirects to the correct favicon asset URL" do
      get favicon_png_path

      expect(response).to redirect_to(favicon_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  describe "GET /favicon.ico" do
    it "redirects to the correct favicon asset URL" do
      get favicon_ico_path

      expect(response).to redirect_to(favicon_url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end
end
