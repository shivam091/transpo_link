# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/color_schemes/update_service_spec.rb

require "spec_helper"

RSpec.describe ColorSchemes::UpdateService, type: :service do
  let!(:user) { create(:admin, :active, :with_address, :confirmed) }

  subject(:service_response) { described_class.(user, color_scheme) }

  context "when valid color scheme is passed" do
    let(:color_scheme) { "dark" }

    it "updates the preferred color scheme" do
      expect { service_response }.to change { user.reload.preferred_color_scheme }.to("dark")
    end

    include_examples "returns a success response"
  end

  context "when invalid color scheme is passed" do
    let(:color_scheme) { "rainbow" }

    it "does not update the preferred color scheme" do
      expect { service_response }.to not_change { user.reload.preferred_color_scheme }
      expect(service_response.http_status).to eq(:bad_request)
    end

    include_examples "returns an error response"
  end

  context "when update fails due to validation error" do
    let(:color_scheme) { "light" }

    before { allow(user).to receive(:update).and_return(false) }

    it "does not update the preferred color scheme" do
      expect { service_response }.to not_change { user.reload.preferred_color_scheme }
      expect(service_response.http_status).to eq(:unprocessable_entity)
    end

    include_examples "returns an error response"
  end
end
