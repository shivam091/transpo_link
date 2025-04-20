# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/profiles/update_service_spec.rb

require "spec_helper"

RSpec.describe Profiles::UpdateService, type: :service do
  let!(:user) { create(:admin, :active, :with_address, :confirmed) }

  subject(:service_response) { described_class.(user, profile_attributes) }

  describe ".call" do
    context "when update is successful" do
      let(:profile_attributes) { {user_detail_attributes: {first_name: "First"}} }

      it "updates the user profile" do
        expect { service_response }.to change { user.reload.first_name }.to("First")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      let(:profile_attributes) { {user_detail_attributes: {first_name: ""}} }

      it "does not update the user profile" do
        expect { service_response }.to not_change { user.reload.first_name }
      end

      include_examples "returns an error response"
    end
  end
end
