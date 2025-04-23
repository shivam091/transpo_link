# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/create_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::CreateService, type: :service do
  let!(:product) { create(:product) }
  let!(:warehouse) { create(:warehouse) }

  subject(:service_response) { described_class.(inventory_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:inventory_attributes) do
        attributes_for(:inventory,
          product_id: product.id,
          warehouse_id: warehouse.id,
          unit_id: product.unit.id
        )
      end

      include_examples "creates a record", Inventory
      include_examples "creates a record", Stock
      include_examples "creates a record", Replenishment
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:inventory_attributes) do
        attributes_for(:inventory,
          product_id: nil,
          warehouse_id: nil,
          unit_id: nil
        )
      end

      include_examples "does not change record count", Inventory
      include_examples "does not change record count", Stock
      include_examples "does not change record count", Replenishment
      include_examples "returns an error response"
    end
  end
end
