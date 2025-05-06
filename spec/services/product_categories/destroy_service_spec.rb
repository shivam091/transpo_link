# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/product_categories/destroy_service_spec.rb

require "spec_helper"

RSpec.describe ProductCategories::DestroyService, type: :service do
  let!(:product_category) { create(:product_category) }

  subject(:service_response) { described_class.(product_category) }

  describe ".call" do
    context "when deletion is successful" do
      include_examples "deletes a record", ProductCategory
      include_examples "returns a success response"
    end

    context "when deletion is unsuccessful" do
      before { allow(product_category).to receive(:destroy) { false } }

      include_examples "does not change record count", ProductCategory
      include_examples "returns an error response"
    end
  end
end
