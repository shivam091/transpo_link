# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/roles/update_service_spec.rb

require "spec_helper"

RSpec.describe Roles::UpdateService, type: :service do
  let!(:role) { create(:admin_role) }

  let(:role_attributes) { {is_active: "true"} }

  subject(:service_response) { described_class.(role, role_attributes) }

  describe ".call" do
    context "when update is successful" do
      it "updates the role" do
        expect { service_response }.to change { role.reload.is_active }.to be_truthy
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(role).to receive(:update) { false } }

      it "does not update the role" do
        expect { service_response }.to not_change { role.reload.is_active }
      end

      include_examples "returns an error response"
    end
  end
end
