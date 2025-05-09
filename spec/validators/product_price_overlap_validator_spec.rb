# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/product_price_overlap_validator_spec.rb

require "spec_helper"

RSpec.describe ProductPriceOverlapValidator do
  let!(:unit) { create(:unit) }
  let!(:product) { create(:product, unit:) }
  let!(:warehouse) { create(:warehouse, unit:) }
  let!(:currency) { "USD" }

  let(:default_attributes) { {product:, warehouse:, unit:, currency:} }

  let!(:existing_product_price) do
    create(:product_price, effective_period: Date.current..(Date.current + 1.month), **default_attributes)
  end

  let!(:overlapping_product_price) do
    build(:product_price, effective_period: (Date.current + 15.days)..(Date.current + 45.days), **default_attributes)
  end

  let!(:new_product_price) do
    build(:product_price, effective_period: Date.current..(Date.current + 1.month), **default_attributes)
  end

  context "when validating overlap with existing product prices" do
    it "adds an error if the product price overlaps with existing prices" do
      new_product_price.product_id = product.id
      new_product_price.effective_period = overlapping_product_price.effective_period

      new_product_price.validate

      expect(new_product_price.errors[:effective_from]).to include("overlaps with an existing price tier")
      expect(new_product_price.errors[:effective_until]).to include("overlaps with an existing price tier")
    end

    it "does not add an error if the product price does not overlap" do
      new_product_price.product_id = product.id
      new_product_price.effective_period = (Date.current + 2.months)..(Date.current + 3.months)

      new_product_price.validate

      expect(new_product_price.errors[:effective_from]).to be_empty
      expect(new_product_price.errors[:effective_until]).to be_empty
    end
  end

  context "when validating overlap with in-memory sibling product prices" do
    it "adds an error if the product price overlaps with an unsaved sibling price" do
      sibling_price = build(:product_price, effective_period: Date.current..(Date.current + 1.month), **default_attributes)

      product.product_prices << sibling_price

      new_product_price.effective_period = sibling_price.effective_period
      new_product_price.validate

      expect(new_product_price.errors[:effective_from]).to include("overlaps with an existing price tier")
      expect(new_product_price.errors[:effective_until]).to include("overlaps with an existing price tier")
    end

    it "does not add an error if the product price does not overlap with an unsaved sibling price" do
      sibling_price = build(:product_price, effective_period: (Date.current + 2.months)..(Date.current + 3.months), **default_attributes)

      product.product_prices << sibling_price

      new_product_price.effective_period = (Date.current + 4.months)..(Date.current + 5.months)
      new_product_price.validate

      expect(new_product_price.errors[:effective_from]).to be_empty
      expect(new_product_price.errors[:effective_until]).to be_empty
    end
  end
end
