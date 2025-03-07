# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/product_categories/update_service_spec.rb

require "spec_helper"

RSpec.describe ProductCategories::UpdateService, type: :service do
  let!(:product_category) { create(:product_category) }
  let(:product_category_attributes) { attributes_for(:product_category, name: "New product category") }
  subject { described_class.(product_category, product_category_attributes) }

  describe "#call" do
    context "when update is successful" do
      it "updates the product category" do
        expect(subject.payload[:product_category].name).to eq("New product category")
        expect(subject.message).to eq("Product category was successfully updated.")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(product_category).to receive(:update) { false } }

      it "does not update the product category" do
        expect(subject.payload[:product_category].name).to eq(product_category.name)
        expect(subject.message).to eq("Product category could not be updated.")
      end

      include_examples "returns an error response"
    end
  end
end
