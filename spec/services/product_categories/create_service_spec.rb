# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/product_categories/create_service_spec.rb

require "spec_helper"

RSpec.describe ProductCategories::CreateService, type: :service do
  subject(:service_response) { described_class.(product_category_attributes) }

  describe ".call" do
    context "when provided attributes are valid" do
      let(:product_category_attributes) { attributes_for(:product_category) }

      include_examples "creates a record", ProductCategory
      include_examples "returns a success response"
    end

    context "when provided attributes are invalid" do
      let(:product_category_attributes) { attributes_for(:product_category, name: "") }

      include_examples "does not change record count", ProductCategory
      include_examples "returns an error response"
    end
  end
end
