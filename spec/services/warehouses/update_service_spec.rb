# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/warehouses/update_service_spec.rb

require "spec_helper"

RSpec.describe Warehouses::UpdateService, type: :service do
  let(:warehouse) { create(:warehouse) }
  let(:warehouse_attributes) { attributes_for(:warehouse, name: "New warehouse") }
  subject { described_class.(warehouse, warehouse_attributes) }

  describe "#call" do
    context "when update is successful" do
      it "updates the warehouse" do
        expect(subject.payload[:warehouse].name).to eq("New warehouse")
        expect(subject.message).to eq("Warehouse was successfully updated.")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(warehouse).to receive(:update).and_return(false) }

      it "does not update the warehouse" do
        expect(subject.payload[:warehouse].name).to eq("TranspoLink Logistics")
        expect(subject.message).to eq("Warehouse could not be updated.")
      end

      include_examples "returns an error response"
    end
  end
end
