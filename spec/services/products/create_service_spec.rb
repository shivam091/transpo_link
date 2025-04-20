# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/products/create_service_spec.rb

require "spec_helper"

RSpec.describe Products::CreateService, type: :service do
  let(:unit) { create(:kilogramme_unit) }

  let!(:product_category) { create(:product_category) }

  subject(:service_response) { described_class.(product_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:product_attributes) do
        attributes_for(:product,
          product_category_id: product_category.id,
          unit_id: unit.id
        )
      end

      include_examples "creates a record", Product
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:product_attributes) do
        attributes_for(:product, product_category_id: nil, unit_id: nil)
      end

      include_examples "does not change record count", Product
      include_examples "returns an error response"
    end
  end
end
