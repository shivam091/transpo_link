# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventory_batches/create_service_spec.rb

require "spec_helper"

RSpec.describe InventoryBatches::CreateService, type: :service do
  let!(:inventory) { create(:inventory) }

  subject(:service_response) { described_class.(inventory, inventory_batch_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:inventory_batch_attributes) do
        attributes_for(:inventory_batch,
          unit_id: inventory.unit_id,
          batch_number: "B123",
          expiration_date: 1.year.from_now
        )
      end

      include_examples "creates a record", InventoryBatch
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:inventory_batch_attributes) do
        attributes_for(:inventory_batch, batch_number: nil)
      end

      include_examples "does not change record count", InventoryBatch
      include_examples "returns an error response"
    end
  end
end
