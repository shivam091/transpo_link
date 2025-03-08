# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_rates/create_service_spec.rb

require "spec_helper"

RSpec.describe TaxRates::CreateService, type: :service do
  subject(:service_response) { described_class.(tax_rate_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:tax_rate_attributes) { attributes_for(:tax_rate) }

      include_examples "creates a record", TaxRate
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:tax_rate_attributes) { {tax_identifier_type: ""} }

      include_examples "does not change record count", TaxRate
      include_examples "returns an error response"
    end
  end
end
