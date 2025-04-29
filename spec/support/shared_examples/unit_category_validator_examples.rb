# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "unit category validator" do
  let!(:product) { create(:product) }

  context "when the unit is in a valid category" do
    let!(:record) { build(factory_name, product:, unit: product.unit) }

    it "does not add validation errors" do
      record.validate

      expect(record.errors[:unit_id]).to be_blank
    end
  end

  context "when the unit is not in a valid category" do
    let(:invalid_unit) { build_stubbed(:kilometre_unit) }

    let!(:record) { build(factory_name, product:, unit: invalid_unit) }

    it "adds an error on unit_id" do
      record.validate

      expect(record.errors[:unit_id]).to include("is incompatible for the selected product")
    end
  end

  context "when product is not present" do
    let!(:record) { build(factory_name, product: nil) }

    it "does not add validation errors" do
      record.validate

      expect(record.errors[:unit_id]).to be_blank
    end
  end
end
