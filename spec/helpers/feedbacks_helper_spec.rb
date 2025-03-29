# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/feedbacks_helper_spec.rb

require "spec_helper"

RSpec.describe FeedbacksHelper, type: :helper do
  let!(:product) { create(:product, name: "Test product") }

  describe "#reviewable_name_with_type" do
    it "returns name with type for a product" do
      expect(helper.reviewable_name_with_type(product)).to eq("Test product (Product)")
    end
  end

  describe "#reviewable_link" do
    it "returns product path for a product" do
      allow(helper).to receive(:product_path).with(product) { "/products/1" }

      expect(helper.reviewable_link(product)).to eq("/products/1")
    end

    it "returns javascript:void(0) for unknown reviewable types" do
      expect(helper.reviewable_link(double("UnknownReviewable"))).to eq("javascript:void(0)")
    end
  end
end
