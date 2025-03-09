# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/profiles/update_service_spec.rb

require "spec_helper"

RSpec.describe Profiles::UpdateService, type: :service do
  let!(:user) { create(:admin, :active, :with_address, :confirmed) }
  let!(:profile_attributes) { {user_detail_attributes: {first_name: "First"}} }

  subject(:service_response) { described_class.(user, profile_attributes) }

  describe ".call" do
    context "when update is successful" do
      it "updates the user profile" do
        expect(service_response.payload[:user].first_name).to eq("First")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(user).to receive(:update) { false } }

      it "does not update the user profile" do
        expect(service_response.payload[:user].first_name).to eq("TranspoLink")
      end

      include_examples "returns an error response"
    end
  end
end
