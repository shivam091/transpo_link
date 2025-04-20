# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/warehouses/update_service_spec.rb

require "spec_helper"

RSpec.describe Warehouses::UpdateService, type: :service do
  let!(:warehouse) { create(:warehouse) }

  subject(:service_response) { described_class.(warehouse, warehouse_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:warehouse_attributes) { {name: "New warehouse"} }

      it "updates the warehouse" do
        expect { service_response }.to change { warehouse.reload.name }.to("New warehouse")
      end

      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:warehouse_attributes) { {name: ""} }

      it "does not update the warehouse" do
        expect { service_response }.to not_change { warehouse.reload.name }
      end

      include_examples "returns an error response"
    end
  end
end
