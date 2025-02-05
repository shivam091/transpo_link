# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/profiles/update_service_spec.rb

require "spec_helper"

RSpec.describe Profiles::UpdateService, type: :service do
  describe "#call" do
    let(:user) { create(:admin, :active, :with_address, :confirmed) }
    let(:profile_attributes) { {user_detail_attributes: {first_name: "First"}} }
    subject { described_class.(user, profile_attributes) }

    context "when update is successful" do
      it "updates the user profile" do
        expect(subject.payload[:user].first_name).to include("First")
        expect(subject.message).to eq("Your profile was successfully updated.")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(user).to receive(:update).and_return(false) }

      it "does not update the user profile" do
        expect(subject.payload[:user].first_name).to include("TranspoLink")
        expect(subject.message).to eq("Your profile could not be updated.")
      end

      include_examples "returns an error response"
    end
  end
end
