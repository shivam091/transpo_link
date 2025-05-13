# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/products/product_prices/destroy_service_spec.rb

require "spec_helper"

RSpec.describe Products::ProductPrices::DestroyService, type: :service do
  let!(:product_price) { create(:product_price) }

  subject(:service_response) { described_class.(product_price) }

  describe ".call" do
    context "when deletion is successful" do
      include_examples "deletes a record", ProductPrice
      include_examples "returns a success response"
    end

    context "when deletion is unsuccessful" do
      before { allow(product_price).to receive(:destroy) { false } }

      include_examples "does not change record count", ProductPrice
      include_examples "returns an error response"
    end
  end
end
