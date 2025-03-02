# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/warehouses/destroy_service_spec.rb

require "spec_helper"

RSpec.describe Warehouses::DestroyService, type: :service do
  let!(:warehouse) { create(:warehouse) }
  subject { described_class.(warehouse) }

  describe "#call" do
    context "when destroy is successful" do
      include_examples "deletes an object", Warehouse

      it "sets flash message" do
        expect(subject.message).to eq("Warehouse was successfully deleted.")
        expect(Warehouse.find_by(id: warehouse.id)).to be_nil
      end

      include_examples "returns a success response"
    end

    context "when destroy fails" do
      before { allow(warehouse).to receive(:destroy) { false } }

      include_examples "does not change count of objects", Warehouse

      it "sets flash message" do
        expect(subject.message).to eq("Warehouse could not be deleted.")
      end

      include_examples "returns an error response"
    end
  end
end
