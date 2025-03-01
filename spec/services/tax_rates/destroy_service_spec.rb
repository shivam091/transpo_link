# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_rates/destroy_service_spec.rb

require "spec_helper"

RSpec.describe TaxRates::DestroyService, type: :service do
  let!(:tax_rate) { create(:tax_rate) }
  subject { described_class.(tax_rate) }

  describe "#call" do
    context "when destroy is successful" do
      include_examples "deletes an object", TaxRate

      it "sets flash message" do
        expect(subject.message).to eq("Tax rate was successfully deleted.")
        expect(TaxRate.find_by(id: tax_rate.id)).to be_nil
      end

      include_examples "returns a success response"
    end

    context "when destroy fails" do
      before { allow(tax_rate).to receive(:destroy) { false } }

      include_examples "does not change count of objects", TaxRate

      it "sets flash message" do
        expect(subject.message).to eq("Tax rate could not be deleted.")
      end

      include_examples "returns an error response"
    end
  end
end
