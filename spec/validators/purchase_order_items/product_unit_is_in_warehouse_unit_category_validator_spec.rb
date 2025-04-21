# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/purchase_order_items/product_unit_is_in_warehouse_unit_category_validator_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrderItems::ProductUnitIsInWarehouseUnitCategoryValidator do
  let(:warehouse) { create(:warehouse) }

  let!(:product) { create(:product) }
  let!(:purchase_order) { create(:purchase_order, warehouse:) }

  context "when the unit is in the valid category" do
    let(:purchase_order_item) { build(:purchase_order_item, purchase_order:, product:) }

    it "does not add validation errors" do
      purchase_order_item.validate

      expect(purchase_order_item.errors[:product_id]).to be_blank
    end
  end

  context "when the unit is not in the valid category" do
    let!(:warehouse) { create(:warehouse, unit: create(:litre_unit)) }
    let!(:purchase_order) { create(:purchase_order, warehouse:) }

    let(:purchase_order_item) { build(:purchase_order_item, purchase_order:, product:) }

    it "adds an error on unit_id" do
      purchase_order_item.validate

      expect(purchase_order_item.errors[:product_id]).to include("is incompatible with the selected warehouse due to unit category mismatch")
    end
  end

  context "when product is not present" do
    let(:purchase_order_item) { build(:purchase_order_item, purchase_order: nil, product:) }

    it "does not add validation errors" do
      purchase_order_item.validate

      expect(purchase_order_item.errors[:product_id]).to be_blank
    end
  end
end
