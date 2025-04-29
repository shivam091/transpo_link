# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/purchase_order_items/destroy_service_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::DestroyService, type: :service do
  let!(:purchase_order_item) { create(:purchase_order_item) }

  subject(:service_response) { described_class.(purchase_order_item) }

  describe ".call" do
    context "when deletion is successful" do
      include_examples "deletes a record", PurchaseOrderItem
      include_examples "returns a success response"
    end

    context "when deletion is unsuccessful" do
      before { allow(purchase_order_item).to receive(:destroy) { false } }

      include_examples "does not change record count", PurchaseOrderItem
      include_examples "returns an error response"
    end
  end
end
