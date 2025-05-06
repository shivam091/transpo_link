# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/restock_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::RestockService, type: :service do
  let!(:inventory) { create(:inventory) }
  let!(:purchase_order_item) { create(:purchase_order_item) }

  subject(:service_response) { described_class.(inventory, purchase_order_item, restock_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:restock_attributes) { attributes_for(:inventory_movement, unit_id: inventory.unit_id) }

      include_examples "creates a record", InventoryMovement
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:restock_attributes) { attributes_for(:inventory_movement, unit_id: nil) }

      include_examples "does not change record count", InventoryMovement
      include_examples "returns an error response"
    end
  end
end
