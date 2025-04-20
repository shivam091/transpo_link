# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/legal_identifiers/update_service_spec.rb

require "spec_helper"

RSpec.describe LegalIdentifiers::UpdateService, type: :service do
  let!(:legal_identifier) { create(:legal_identifier) }

  let(:legal_identifier_attributes) { {tax_identifier: "32AAHHS1234A2Z4"} }

  subject(:service_response) { described_class.(legal_identifier, legal_identifier_attributes) }

  describe ".call" do
    context "when update is successful" do
      it "updates the legal identifier" do
        expect { service_response }.to change { legal_identifier.reload.tax_identifier }.to("32AAHHS1234A2Z4")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(legal_identifier).to receive(:update) { false } }

      it "does not update the legal identifier" do
        expect { service_response }.to not_change { legal_identifier.reload.tax_identifier }
      end

      include_examples "returns an error response"
    end
  end
end
