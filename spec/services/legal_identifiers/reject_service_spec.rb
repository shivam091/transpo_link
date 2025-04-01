# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/legal_identifiers/reject_service_spec.rb

require "spec_helper"

RSpec.describe LegalIdentifiers::RejectService, type: :service do
  let!(:legal_identifier) { create(:legal_identifier) }

  subject(:service_response) { described_class.(legal_identifier) }

  describe ".call" do
    context "when reject is successful" do
      it "rejects the legal identifier" do
        expect { service_response }.to change { legal_identifier.reload.status }.to("rejected")
        expect(legal_identifier.rejected?).to be_truthy
      end

      include_examples "returns a success response"
    end

    context "when reject fails" do
      before { allow(legal_identifier).to receive(:reject!) { false } }

      it "does not reject the legal identifier" do
        expect { service_response }.to not_change { legal_identifier.reload.status }
        expect(legal_identifier.rejected?).to be_falsy
      end

      include_examples "returns an error response"
    end
  end
end
