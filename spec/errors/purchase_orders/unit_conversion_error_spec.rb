# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/errors/purchase_orders/unit_conversion_error_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::UnitConversionError do
  let(:product) { double("Product", name: "Test Product") }
  let(:error) { described_class.new(product) }

  it "inherits from ApplicationError" do
    expect(error).to be_a(PurchaseOrders::PurchaseOrderError)
  end

  it "has the correct i18n_key and context" do
    expect(error.i18n_key).to eq(:unit_conversion_failed)
    expect(error.context).to eq({product_name: "Test Product"})
  end

  it "returns a translated message" do
    allow(I18n).to receive(:t).with(:unit_conversion_failed, scope: "errors.purchase_orders", product_name: "Test Product") { "Cannot convert unit for Test Product" }
    expect(error.message).to eq("Cannot convert unit for Test Product")
  end
end
