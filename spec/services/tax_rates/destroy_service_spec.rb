# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_rates/destroy_service_spec.rb

require "spec_helper"

RSpec.describe TaxRates::DestroyService, type: :service do
  let!(:tax_rate) { create(:tax_rate) }

  subject(:service_response) { described_class.(tax_rate) }

  describe ".call" do
    context "when deletion is successful" do
      include_examples "deletes a record", TaxRate
      include_examples "returns a success response"
    end

    context "when deletion is unsuccessful" do
      before { allow(tax_rate).to receive(:destroy) { false } }

      include_examples "does not change record count", TaxRate
      include_examples "returns an error response"
    end
  end
end
