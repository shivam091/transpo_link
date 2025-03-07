# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/product_categories/create_service_spec.rb

require "spec_helper"

RSpec.describe ProductCategories::CreateService, type: :service do
  subject { described_class.(product_category_attributes) }

  describe "#call" do
    context "when product category is valid" do
      let(:product_category_attributes) { attributes_for(:product_category) }

      include_examples "creates a new object", ProductCategory

      it "sets flash message" do
        expect(subject.message).to eq("Product category was successfully created.")
      end

      include_examples "returns a success response"
    end

    context "when product category is invalid" do
      let(:product_category_attributes) { attributes_for(:product_category, name: "") }

      include_examples "does not change count of objects", ProductCategory

      it "sets flash message" do
        expect(subject.message).to eq("Product category could not be created.")
      end

      include_examples "returns an error response"
    end
  end
end
