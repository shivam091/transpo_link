# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/tax_details/create_service_spec.rb

require "spec_helper"

RSpec.describe TaxDetails::CreateService, type: :service do
  let!(:user) { create(:buyer) }
  subject { described_class.(user, tax_detail_attributes) }

  describe "#call" do
    context "when tax detail is valid" do
      let(:tax_detail_attributes) { attributes_for(:tax_detail) }

      include_examples "creates a new object", TaxDetail

      it "sets flash message" do
        expect(subject.message).to eq("Tax detail was successfully created.")
      end

      include_examples "returns a success response"
    end

    context "when tax detail is invalid" do
      let(:tax_detail_attributes) { attributes_for(:tax_detail, tax_type: "") }

      include_examples "does not change count of objects", TaxDetail

      it "sets flash message" do
        expect(subject.message).to eq("Tax detail could not be created.")
      end

      include_examples "returns an error response"
    end
  end
end
