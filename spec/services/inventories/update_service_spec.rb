# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/update_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::UpdateService, type: :service do
  let!(:inventory) { create(:inventory, batch_number: "B123456789") }
  let!(:inventory_attributes) { {batch_number: "B987654321"} }

  subject(:service_response) { described_class.(inventory, inventory_attributes) }

  describe ".call" do
    context "when update is successful" do
      it "updates the inventory" do
        expect(service_response.payload[:inventory].batch_number).to eq("B987654321")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(inventory).to receive(:update) { false } }

      it "does not update the inventory" do
        expect(service_response.payload[:inventory].batch_number).to eq("B123456789")
      end

      include_examples "returns an error response"
    end
  end
end
