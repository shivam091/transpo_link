# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/preferences/update_service_spec.rb

require "spec_helper"

RSpec.describe Preferences::UpdateService, type: :service do
  let!(:user) { create(:admin, :active, :with_address, :confirmed) }

  subject(:service_response) { described_class.(user, preference_attributes) }

  describe ".call" do
    context "when update is successful" do
      let(:preference_attributes) { {user_preference_attributes: {preferred_currency: "GBP"}} }

      it "updates the user preferences" do
        expect { service_response }.to change { user.reload.preferred_currency }.to("GBP")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      let(:preference_attributes) { {user_preference_attributes: {preferred_currency: ""}} }

      it "does not update the user preferences" do
        expect { service_response }.to not_change { user.reload.preferred_currency }
      end

      include_examples "returns an error response"
    end
  end
end
