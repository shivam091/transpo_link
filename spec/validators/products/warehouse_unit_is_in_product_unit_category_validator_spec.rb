# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/products/warehouse_unit_is_in_product_unit_category_validator_spec.rb

require "spec_helper"

RSpec.describe Products::WarehouseUnitIsInProductUnitCategoryValidator do
  let!(:product) { create(:product) }

  context "when the product unit matches warehouse capacity unit category" do
    let!(:warehouse) { create(:warehouse) }

    let(:product_price) { build(:product_price, warehouse:, product:) }

    it "does not add validation errors" do
      product_price.validate

      expect(product_price.errors[:warehouse_id]).to be_blank
    end
  end

  context "when the product unit does not match warehouse capacity unit category" do
    let!(:litre_unit) { create(:litre_unit) }
    let!(:warehouse) { create(:warehouse, unit: litre_unit) }

    let(:product_price) { build(:product_price, warehouse:, product:) }

    it "adds an error on unit_id" do
      product_price.validate

      expect(product_price.errors[:warehouse_id]).to include("is incompatible with this product due to a capacity unit mismatch")
    end
  end

  context "when warehouse is not present" do
    let(:product_price) { build(:product_price, warehouse: nil, product:) }

    it "skips validation when warehouse is nil" do
      product_price.validate

      expect(product_price.errors[:warehouse_id]).to be_blank
    end
  end
end
