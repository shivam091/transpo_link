# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/legal_identifiers/approve_service_spec.rb

require "spec_helper"

RSpec.describe LegalIdentifiers::ApproveService, type: :service do
  let!(:legal_identifier) { create(:legal_identifier) }

  subject(:service_response) { described_class.(legal_identifier) }

  describe ".call" do
    context "when approve is successful" do
      it "approves the legal identifier" do
        expect { service_response }.to change { legal_identifier.reload.status }.to("approved")
      end

      include_examples "returns a success response"
    end

    context "when approve fails" do
      before { allow(legal_identifier).to receive(:approve!) { false } }

      it "does not approve the legal identifier" do
        expect { service_response }.to not_change { legal_identifier.reload.status }
      end

      include_examples "returns an error response"
    end
  end
end
