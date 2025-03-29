# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/locales/update_service_spec.rb

require "spec_helper"

RSpec.describe Locales::UpdateService, type: :service do
  let!(:user) { create(:admin, :active, :with_address, :confirmed) }
  let(:preference_attributes) { {user_preference_attributes: {preferred_locale: "es"}} }

  subject(:service_response) { described_class.(user, preference_attributes) }

  after { I18n.locale = :en }

  describe ".call" do
    context "when update is successful" do
      it "updates the language" do
        expect { service_response }.to change { user.reload.preferred_locale }.to("es")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(user).to receive(:update) { false } }

      it "does not update the language" do
        expect { service_response }.to not_change { user.reload.preferred_locale }
      end

      include_examples "returns an error response"
    end
  end
end
