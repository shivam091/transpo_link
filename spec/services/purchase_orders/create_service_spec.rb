# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/create_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::CreateService, type: :service do
  let!(:warehouse) { create(:warehouse) }

  let(:manager) { warehouse.managers.first }
  let(:supplier) { warehouse.suppliers.first }

  subject(:service_response) { described_class.(manager, purchase_order_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:purchase_order_attributes) do
        attributes_for(:purchase_order,
          warehouse_id: warehouse.id,
          manager_id: manager.id,
          supplier_id: supplier.id
        )
      end

      include_examples "creates a record", PurchaseOrder
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:purchase_order_attributes) do
        attributes_for(:purchase_order,
          warehouse_id: nil,
          manager_id: nil,
          supplier_id: nil
        )
      end

      include_examples "does not change record count", PurchaseOrder
      include_examples "returns an error response"
    end
  end
end
