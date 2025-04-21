# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/purchase_orders/no_duplicate_product_validator_spec.rb

require "spec_helper"

RSpec.describe PurchaseOrders::NoDuplicateProductValidator do
  let(:purchase_order) { create(:purchase_order) }
  let(:product) { create(:product) }
  let(:unit) { create(:unit) }

  subject(:item) { build(:purchase_order_item, purchase_order:, product:, unit:) }

  before do
    # Ensure the association is preloaded as required by the validator
    purchase_order.purchase_order_items.to_a
  end

  context "when item is marked for destruction" do
    it "does not add validation error" do
      item.mark_for_destruction
      item.valid?

      expect(item.errors[:product_id]).to be_empty
    end
  end

  context "when purchase order is not present" do
    before { item.purchase_order = nil }

    it "does not add validation error" do
      item.valid?

      expect(item.errors[:product_id]).to be_empty
    end
  end

  context "when purchase order items are not loaded" do
    it "skips validation if not preloaded" do
      allow(item.purchase_order.purchase_order_items).to receive(:loaded?) { false }

      item.valid?

      expect(item.errors[:product_id]).to be_empty
    end
  end

  context "when it is the only item with the product" do
    it "is valid" do
      expect(item).to be_valid
    end
  end

  context "when there are two items with the same product" do
    let!(:existing_item) { create(:purchase_order_item, purchase_order:, product:, unit:) }

    it "adds a validation error to the second item" do
      expect(item).to be_invalid
      expect(item.errors[:product_id]).to include("has already been added to this purchase order")
    end
  end

  context "when duplicate item is marked for destruction" do
    let!(:existing_item) do
      create(:purchase_order_item, purchase_order:, product:, unit:).tap(&:mark_for_destruction)
    end

    it "is valid since other item is being destroyed" do
      expect(item).to be_valid
    end
  end

  context "when current item is the first duplicate" do
    let!(:item) { create(:purchase_order_item, purchase_order:, product:, unit:) }
    let!(:other_item) { build(:purchase_order_item, purchase_order:, product:, unit:) }

    it "does not add error on the first matching item" do
      purchase_order.purchase_order_items << [item, other_item]

      expect(item).to be_valid
      expect(other_item).to be_invalid
      expect(other_item.errors[:product_id]).to include("has already been added to this purchase order")
    end
  end
end
