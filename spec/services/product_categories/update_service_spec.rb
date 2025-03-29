# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/services/product_categories/update_service_spec.rb

require "spec_helper"

RSpec.describe ProductCategories::UpdateService, type: :service do
  let!(:product_category) { create(:product_category) }
  let(:product_category_attributes) { {name: "New product category"} }

  subject(:service_response) { described_class.(product_category, product_category_attributes) }

  describe ".call" do
    context "when update is successful" do
      it "updates the product category" do
        expect { service_response }.to change { product_category.reload.name }.to("New product category")
      end

      include_examples "returns a success response"
    end

    context "when update fails" do
      before { allow(product_category).to receive(:update) { false } }

      it "does not update the product category" do
        expect { service_response }.to not_change { product_category.reload.name }
      end

      include_examples "returns an error response"
    end
  end
end
