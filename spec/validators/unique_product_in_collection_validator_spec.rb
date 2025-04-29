  # -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/validators/unique_product_in_collection_validator_spec.rb

require "spec_helper"

RSpec.describe UniqueProductInCollectionValidator do
  context "when validating the purchase order" do
    let(:parent) { :purchase_order }
    let(:child_collection) { :purchase_order_items }
    let(:parent_factory) { :purchase_order }
    let(:child_factory) { :purchase_order_item }

    include_examples "a unique product in collection validator"
  end
end
