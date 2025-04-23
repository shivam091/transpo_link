# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/replenishments/create_service_spec.rb

require "spec_helper"

RSpec.describe Replenishments::CreateService, type: :service do
  subject(:service_response) { described_class.(inventory) }

  before { allow_any_instance_of(Inventory).to receive(:create_replenishment) }

  describe ".call" do
    context "with a valid inventory" do
      let(:inventory) { create(:inventory) }

      include_examples "creates a record", Replenishment
    end

    context "with an invalid inventory (nil)" do
      let(:inventory) { nil }

      it "raises ActiveRecord::RecordInvalid" do
        expect { service_response }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
