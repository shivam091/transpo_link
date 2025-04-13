# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/errors/purchase_orders/purchase_order_error_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::PurchaseOrderError do
  let(:error) { described_class.new(:some_error, context: {example: "value"}) }

  describe "#default_scope" do
    it "returns the purchase_orders error scope" do
      expect(error.default_scope).to eq("errors.purchase_orders")
    end
  end

  describe "#message" do
    it "uses the purchase_orders scope for I18n" do
      allow(I18n).to receive(:t).with(:some_error, scope: "errors.purchase_orders", example: "value") { "Purchase order error" }
      expect(error.message).to eq("Purchase order error")
    end
  end
end
