# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_orders/destroy_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::DestroyService, type: :service do
  let!(:purchase_order) { create(:purchase_order) }

  subject(:service_response) { described_class.(purchase_order) }

  describe ".call" do
    context "when deletion is successful" do
      include_examples "deletes a record", PurchaseOrder
      include_examples "returns a success response"
    end

    context "when deletion is unsuccessful" do
      before { allow(purchase_order).to receive(:destroy) { false } }

      include_examples "does not change record count", PurchaseOrder
      include_examples "returns an error response"
    end
  end
end
