# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/products/update_service_spec.rb

require "spec_helper"

RSpec.describe Products::UpdateService, type: :service do
  let!(:product) { create(:product, name: "Product") }
  let!(:product_attributes) { {name: "New product"} }

  subject(:service_response) { described_class.(product, product_attributes) }

  describe ".call" do
    context "when update is successful" do
      it "updates the tax rate" do
        expect(service_response.payload[:product].name).to eq("New product")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(product).to receive(:update) { false } }

      it "does not update the tax rate" do
        expect(service_response.payload[:product].name).to eq("Product")
      end

      include_examples "returns an error response"
    end
  end
end
