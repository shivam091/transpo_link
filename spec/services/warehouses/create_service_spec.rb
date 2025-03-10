# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/warehouses/create_service_spec.rb

require "spec_helper"

RSpec.describe Warehouses::CreateService, type: :service do
  subject(:service_response) { described_class.(warehouse_attributes) }

  describe ".call" do
    let(:manager) { create(:manager) }
    let(:supplier) { create(:supplier) }

    context "when provided attributes are valid" do
      let(:warehouse_attributes) { attributes_for(:warehouse).merge(manager_ids: [manager.id], supplier_ids: [supplier.id]) }

      include_examples "creates a record", Warehouse
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:warehouse_attributes) { attributes_for(:warehouse, name: "") }

      include_examples "does not change record count", Warehouse
      include_examples "returns an error response"
    end
  end
end
