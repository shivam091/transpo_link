# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/products/product_prices/create_service_spec.rb

require "spec_helper"

RSpec.describe Products::ProductPrices::CreateService, type: :service do
  let(:unit) { create(:kilogramme_unit) }

  let!(:product) { create(:product, unit:) }

  subject(:service_response) { described_class.(product, product_price_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:product_price_attributes) { attributes_for(:product_price, unit_id: unit.id) }

      include_examples "creates a record", ProductPrice
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:product_price_attributes) { attributes_for(:product_price, unit_id: nil) }

      include_examples "does not change record count", ProductPrice
      include_examples "returns an error response"
    end
  end
end
