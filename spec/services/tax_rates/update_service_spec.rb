# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_rates/update_service_spec.rb

require "spec_helper"

RSpec.describe TaxRates::UpdateService, type: :service do
  let(:tax_rate) { create(:tax_rate) }
  let(:tax_rate_attributes) { attributes_for(:tax_rate, tax_type: "tin") }
  subject { described_class.(tax_rate, tax_rate_attributes) }

  describe "#call" do
    context "when update is successful" do
      it "updates the tax rate" do
        expect(subject.payload[:tax_rate].tax_type).to eq("tin")
        expect(subject.message).to eq("Tax rate was successfully updated.")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(tax_rate).to receive(:update) { false } }

      it "does not update the tax rate" do
        expect(subject.payload[:tax_rate].tax_type).to eq("vat")
        expect(subject.message).to eq("Tax rate could not be updated.")
      end

      include_examples "returns an error response"
    end
  end
end
