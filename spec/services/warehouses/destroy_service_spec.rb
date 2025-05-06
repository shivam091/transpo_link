# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/warehouses/destroy_service_spec.rb

require "spec_helper"

RSpec.describe Warehouses::DestroyService, type: :service do
  let!(:warehouse) { create(:warehouse) }

  subject(:service_response) { described_class.(warehouse) }

  describe ".call" do
    context "when deletion is successful" do
      include_examples "deletes a record", Warehouse
      include_examples "returns a success response"
    end

    context "when deletion is unsuccessful" do
      before { allow(warehouse).to receive(:destroy) { false } }

      include_examples "does not change record count", Warehouse
      include_examples "returns an error response"
    end
  end
end
