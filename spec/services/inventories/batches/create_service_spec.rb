# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/batches/create_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::Batches::CreateService, type: :service do
  let!(:inventory) { create(:inventory) }

  subject(:service_response) { described_class.(inventory, batch_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:batch_attributes) do
        attributes_for(:inventory_batch,
          unit_id: inventory.unit_id,
          batch_number: "B123",
          expiration_date: 1.year.from_now
        )
      end

      include_examples "creates a record", Inventory::Batch
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:batch_attributes) do
        attributes_for(:inventory_batch, batch_number: nil, expiration_date: nil)
      end

      include_examples "does not change record count", Inventory::Batch
      include_examples "returns an error response"
    end
  end
end
