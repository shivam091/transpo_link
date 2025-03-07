# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/product_categories/destroy_service_spec.rb

require "spec_helper"

RSpec.describe ProductCategories::DestroyService, type: :service do
  let!(:product_category) { create(:product_category) }
  subject { described_class.(product_category) }

  describe "#call" do
    context "when destroy is successful" do
      include_examples "deletes an object", ProductCategory

      it "sets flash message" do
        expect(subject.message).to eq("Product category was successfully deleted.")
        expect(ProductCategory.find_by(id: product_category.id)).to be_nil
      end

      include_examples "returns a success response"
    end

    context "when destroy fails" do
      before { allow(product_category).to receive(:destroy) { false } }

      include_examples "does not change count of objects", ProductCategory

      it "sets flash message" do
        expect(subject.message).to eq("Product category could not be deleted.")
      end

      include_examples "returns an error response"
    end
  end
end
