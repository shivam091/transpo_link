# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/unit_conversions_spec.rb

require "spec_helper"

RSpec.describe "UnitConversions", type: :request do
  let!(:unit_conversion) { create(:dozen_item_conversion) }

  include_context "sign in as admin"

  describe "GET /unit-conversions" do
    it "renders list of all unit conversions with pagination" do
      get unit_conversions_path

      expect(controller_assigns(:unit_conversions)).to include(unit_conversion)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end
end
