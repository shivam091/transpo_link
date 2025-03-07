# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/legal_identifiers/destroy_service_spec.rb

require "spec_helper"

RSpec.describe LegalIdentifiers::DestroyService, type: :service do
  let!(:legal_identifier) { create(:legal_identifier) }
  subject { described_class.(legal_identifier) }

  describe "#call" do
    context "when destroy is successful" do
      include_examples "deletes an object", LegalIdentifier

      it "sets flash message" do
        expect(subject.message).to eq("Legal identifier was successfully deleted.")
        expect(LegalIdentifier.find_by(id: legal_identifier.id)).to be_nil
      end

      include_examples "returns a success response"
    end

    context "when destroy fails" do
      before { allow(legal_identifier).to receive(:destroy) { false } }

      include_examples "does not change count of objects", LegalIdentifier

      it "sets flash message" do
        expect(subject.message).to eq("Legal identifier could not be deleted.")
      end

      include_examples "returns an error response"
    end
  end
end
