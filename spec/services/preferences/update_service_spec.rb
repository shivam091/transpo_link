# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/preferences/update_service_spec.rb

require "spec_helper"

RSpec.describe Preferences::UpdateService, type: :service do
  describe "#call" do
    let(:user) { create(:admin, :active, :with_address, :confirmed) }
    let(:preference_attributes) { {user_preference_attributes: {preferred_currency: "GBP"}} }
    subject { described_class.(user, preference_attributes) }

    context "when update is successful" do
      it "updates the user preferences" do
        expect(subject.payload[:user].preferred_currency).to include("GBP")
        expect(subject.message).to eq("Your preferences were successfully updated.")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(user).to receive(:update).and_return(false) }

      it "does not update the user preferences" do
        expect(subject.payload[:user].preferred_currency).to include("INR")
        expect(subject.message).to eq("Your preferences could not be updated.")
      end

      include_examples "returns an error response"
    end
  end
end
