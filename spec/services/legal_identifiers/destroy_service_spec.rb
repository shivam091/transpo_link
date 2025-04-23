# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/legal_identifiers/destroy_service_spec.rb

require "spec_helper"

RSpec.describe LegalIdentifiers::DestroyService, type: :service do
  let!(:legal_identifier) { create(:legal_identifier) }

  subject(:service_response) { described_class.(legal_identifier) }

  describe ".call" do
    context "when deletion is successful" do
      include_examples "deletes a record", LegalIdentifier
      include_examples "returns a success response"
    end

    context "when deletion is unsuccessful" do
      before { allow(legal_identifier).to receive(:destroy) { false } }

      include_examples "does not change record count", LegalIdentifier
      include_examples "returns an error response"
    end
  end
end
