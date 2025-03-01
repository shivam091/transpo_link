# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_rates/create_service_spec.rb

require "spec_helper"

RSpec.describe TaxRates::CreateService, type: :service do
  subject { described_class.(tax_rate_attributes) }

  describe "#call" do
    context "when tax rate is valid" do
      let(:tax_rate_attributes) { attributes_for(:tax_rate) }

      include_examples "creates a new object", TaxRate

      it "sets flash message" do
        expect(subject.message).to eq("Tax rate was successfully created.")
      end

      include_examples "returns a success response"
    end

    context "when tax rate is invalid" do
      let(:tax_rate_attributes) { attributes_for(:tax_rate, tax_type: "") }

      include_examples "does not change count of objects", TaxRate

      it "sets flash message" do
        expect(subject.message).to eq("Tax rate could not be created.")
      end

      include_examples "returns an error response"
    end
  end
end
