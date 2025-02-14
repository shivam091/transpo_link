# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/locales/update_service_spec.rb

require "spec_helper"

RSpec.describe Locales::UpdateService, type: :service do
  describe "#call" do
    let(:user) { create(:admin, :active, :with_address, :confirmed) }
    let(:preference_attributes) { {user_preference_attributes: {preferred_locale: "en"}} }
    subject { described_class.(user, preference_attributes) }

    context "when update is successful" do
      it "updates the language" do
        expect(subject.payload[:user].preferred_locale).to include("en")
        expect(subject.message).to eq("You've updated your language. Your change might take a while to show everywhere.")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(user).to receive(:update).and_return(false) }

      it "does not update the language" do
        expect(subject.payload[:user].preferred_locale).to include("en")
        expect(subject.message).to eq("Your language could not be updated.")
      end

      include_examples "returns an error response"
    end
  end
end
