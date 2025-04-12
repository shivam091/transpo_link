# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/inventories/create_service_spec.rb

require "spec_helper"

RSpec.describe Inventories::CreateService, type: :service do
  let(:unit) { create(:kilogramme_unit) }

  let!(:product) { create(:product, unit:) }
  let!(:warehouse) { create(:warehouse) }

  subject(:service_response) { described_class.(inventory_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:inventory_attributes) { attributes_for(:inventory).merge(product_id: product.id, warehouse_id: warehouse.id, unit_id: unit.id) }

      include_examples "creates a record", Inventory
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:inventory_attributes) { {product_id: ""} }

      include_examples "does not change record count", Inventory
      include_examples "returns an error response"
    end
  end
end
