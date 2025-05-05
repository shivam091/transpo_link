# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/requests/inventories/batches_spec.rb

require "spec_helper"

RSpec.describe "Inventories::Batches", type: :request do
  let(:inventory) { create(:inventory) }
  let!(:batch1) { create(:inventory_batch, inventory:) }
  let!(:batch2) { create(:inventory_batch, inventory:) }

  include_context "sign in as manager"

  describe "GET /inventories/:inventory_id/batches" do
    it "renders list of all batches in turbo frame" do
      get inventory_batches_path(inventory), headers: {"Turbo-Frame" => dom_id(inventory, :batches)}

      expect(controller_assigns(:inventory)).to eq(inventory)
      expect(controller_assigns(:batches)).to match_array([batch1, batch2])

      expect(response.body).to include(batch1.batch_number)
      expect(response.body).to include(batch2.batch_number)
      expect(response.body).not_to include("<html>") # Should be just a partial

      expect(response).to have_http_status(:ok)
    end
  end
end
