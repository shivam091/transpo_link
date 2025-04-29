# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/unit_is_in_product_unit_category_validator_spec.rb

require "spec_helper"

RSpec.describe UnitIsInProductUnitCategoryValidator do
  context "when validating the purchase order item" do
    let(:factory_name) { :purchase_order_item }

    include_examples "unit category validator"
  end

  context "when validating the inventory" do
    let(:factory_name) { :inventory }

    include_examples "unit category validator"
  end
end
