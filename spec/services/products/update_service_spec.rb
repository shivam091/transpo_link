# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/products/update_service_spec.rb

require "spec_helper"

RSpec.describe Products::UpdateService, type: :service do
  let!(:product) { create(:product) }

  subject(:service_response) { described_class.(product, product_attributes) }

  describe ".call" do
    context "when update is successful" do
      let(:product_attributes) { {name: "New product"} }

      it "updates the product" do
        expect { service_response }.to change { product.reload.name }.to("New product")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      let(:product_attributes) { {name: ""} }

      it "does not update the product" do
        expect { service_response }.to not_change { product.reload.name }
      end

      include_examples "returns an error response"
    end
  end
end
