# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/legal_identifiers/create_service_spec.rb

require "spec_helper"

RSpec.describe LegalIdentifiers::CreateService, type: :service do
  let!(:user) { create(:buyer) }

  subject(:service_response) { described_class.(user, legal_identifier_attributes) }

  describe ".call" do
    context "when legal identifier is valid" do
      let(:legal_identifier_attributes) { attributes_for(:legal_identifier) }

      include_examples "creates a record", LegalIdentifier
      include_examples "returns a success response"
    end

    context "when legal identifier is invalid" do
      let(:legal_identifier_attributes) { {tax_identifier_type: ""} }

      include_examples "does not change record count", LegalIdentifier
      include_examples "returns an error response"
    end
  end
end
