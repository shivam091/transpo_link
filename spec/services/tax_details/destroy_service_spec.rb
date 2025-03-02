# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_details/destroy_service_spec.rb

require "spec_helper"

RSpec.describe TaxDetails::DestroyService, type: :service do
  let!(:tax_detail) { create(:tax_detail) }
  subject { described_class.(tax_detail) }

  describe "#call" do
    context "when destroy is successful" do
      include_examples "deletes an object", TaxDetail

      it "sets flash message" do
        expect(subject.message).to eq("Tax detail was successfully deleted.")
        expect(TaxDetail.find_by(id: tax_detail.id)).to be_nil
      end

      include_examples "returns a success response"
    end

    context "when destroy fails" do
      before { allow(tax_detail).to receive(:destroy) { false } }

      include_examples "does not change count of objects", TaxDetail

      it "sets flash message" do
        expect(subject.message).to eq("Tax detail could not be deleted.")
      end

      include_examples "returns an error response"
    end
  end
end
