# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/inventories/product_warehouse_unit_category_validator_spec.rb

require "spec_helper"

RSpec.describe Inventories::ProductWarehouseUnitCategoryValidator do
  let!(:product) { create(:product) }

  context "when the product unit matches warehouse capacity unit category" do
    let!(:warehouse) { create(:warehouse) }

    let(:inventory) { build(:inventory, warehouse:, product:) }

    it "does not add validation errors" do
      inventory.validate

      expect(inventory.errors[:product_id]).to be_blank
    end
  end

  context "when the product unit does not match warehouse capacity unit category" do
    let!(:litre_unit) { create(:litre_unit) }
    let!(:warehouse) { create(:warehouse, unit: litre_unit) }

    let(:inventory) { build(:inventory, warehouse:, product:) }

    it "adds an error on unit_id" do
      inventory.validate

      expect(inventory.errors[:product_id]).to include("is incompatible for the selected warehouse")
    end
  end

  context "when warehouse is not present" do
    let(:inventory) { build(:inventory, warehouse: nil, product:) }

    it "skips validation when warehouse is nil" do
      inventory.validate

      expect(inventory.errors[:product_id]).to be_blank
    end
  end
end
