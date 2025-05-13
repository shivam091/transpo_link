# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/products/product_prices/update_service_spec.rb

require "spec_helper"

RSpec.describe Products::ProductPrices::UpdateService, type: :service do
  let!(:product_price) { create(:product_price) }

  subject(:service_response) { described_class.(product_price, product_price_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:product_price_attributes) { attributes_for(:product_price, min_quantity: 10.0) }

      it "updates the product price" do
        expect { service_response }.to change { product_price.reload.min_quantity }.to(10.0)
      end

      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:product_price_attributes) { attributes_for(:product_price, min_quantity: nil) }

      it "does not update the product price" do
        expect { service_response }.to not_change { product_price.reload.min_quantity }
      end

      include_examples "returns an error response"
    end
  end
end
