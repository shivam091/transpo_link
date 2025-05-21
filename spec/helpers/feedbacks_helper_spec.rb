# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/feedbacks_helper_spec.rb

require "spec_helper"

RSpec.describe FeedbacksHelper, type: :helper do
  let!(:product) { build_stubbed(:product, name: "Test product") }

  describe "#reviewable_label" do
    it "returns name with type for a product" do
      expect(helper.reviewable_label(product)).to eq("Test product (Product)")
    end
  end

  describe "#reviewable_path" do
    it "returns product path for a product" do
      expect(helper.reviewable_path(product)).to eq(product_path(product))
    end

    it "returns javascript:void(0) for unknown reviewable types" do
      expect(helper.reviewable_path(double("UnknownReviewable"))).to eq("javascript:void(0)")
    end
  end

  describe "#link_to_reviewable" do
    let(:user) { build_stubbed(:user) }
    let(:ability) { instance_double("Ability") }

    before do
      allow(helper).to receive(:can_view_reviewable?) { true }
    end

    it "returns link for reviewable" do
      expect(helper.link_to_reviewable(product)).to eq(
        link_to("Test product (Product)", product_path(product))
      )
    end
  end
end
