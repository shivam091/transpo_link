# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/units_spec.rb

require "spec_helper"

RSpec.describe "Units", type: :request do
  let!(:unit) { create(:item_unit) }

  include_context "sign in as admin"

  describe "GET /units" do
    it "renders list of all units with pagination" do
      get units_path

      expect(controller_assigns(:units)).to include(unit)
      expect(controller_assigns(:pagination_metadata)).to be_present
      expect(response).to have_http_status(:ok)
    end
  end
end
