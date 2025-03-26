# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_rates/update_service_spec.rb

require "spec_helper"

RSpec.describe TaxRates::UpdateService, type: :service do
  let!(:tax_rate) { create(:tax_rate) }
  let(:tax_rate_attributes) { {tax_identifier_type: "pan"} }

  subject(:service_response) { described_class.(tax_rate, tax_rate_attributes) }

  describe ".call" do
    context "when update is successful" do
      it "updates the tax rate" do
        expect { service_response }.to change { tax_rate.reload.tax_identifier_type }.to("pan")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(tax_rate).to receive(:update) { false } }

      it "does not update the tax rate" do
        expect { service_response }.to not_change { tax_rate.reload.tax_identifier_type }
      end

      include_examples "returns an error response"
    end
  end
end
