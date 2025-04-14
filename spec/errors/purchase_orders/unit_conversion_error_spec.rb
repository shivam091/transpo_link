# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/errors/purchase_orders/unit_conversion_error_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::UnitConversionError do
  let(:source_unit) { double("Unit", symbol: "kg") }
  let(:target_unit) { double("Unit", symbol: "g") }
  let(:error) { described_class.new(source_unit, target_unit) }

  it "inherits from ApplicationError" do
    expect(error).to be_a(PurchaseOrders::PurchaseOrderError)
  end

  it "has the correct i18n_key and context" do
    expect(error.i18n_key).to eq(:unit_conversion_failed)
    expect(error.context).to eq({source_unit: "Kilogramme (kg)", target_unit: "Gramme (g)"})
  end

  it "returns a translated message" do
    allow(I18n).to receive(:t).with("kg", scope: "measurement_units.sub_categories") { "Kilogramme (kg)" }
    allow(I18n).to receive(:t).with("g", scope: "measurement_units.sub_categories") { "Gramme (g)" }
    allow(I18n).to receive(:t).with(:unit_conversion_failed, scope: "errors.purchase_orders", source_unit: "Kilogramme (kg)", target_unit: "Gramme (g)") { 'Cannot convert from "Kilogramme (kg)" to "Gramme (g)"' }

    expect(error.message).to eq('Cannot convert from "Kilogramme (kg)" to "Gramme (g)"')
  end
end
