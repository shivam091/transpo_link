# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_details/update_service_spec.rb

require "spec_helper"

RSpec.describe TaxDetails::UpdateService, type: :service do
  let(:tax_detail) { create(:tax_detail) }
  let(:tax_detail_attributes) { attributes_for(:tax_detail, tax_number: "27ABCDE1234B1Z6") }
  subject { described_class.(tax_detail, tax_detail_attributes) }

  describe "#call" do
    context "when update is successful" do
      it "updates the tax detail" do
        expect(subject.payload[:tax_detail].tax_number).to eq("27ABCDE1234B1Z6")
        expect(subject.message).to eq("Tax detail was successfully updated.")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(tax_detail).to receive(:update) { false } }

      it "does not update the tax detail" do
        expect(subject.payload[:tax_detail].tax_number).to eq("27ABCDE1234B1Z5")
        expect(subject.message).to eq("Tax detail could not be updated.")
      end

      include_examples "returns an error response"
    end
  end
end
