# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/product_category_spec.rb

require "spec_helper"

RSpec.describe ProductCategory, type: :model do
  subject(:product_category) { build(:product_category) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:product_category) }
    it { is_expected.to have_a_valid_factory(:product_sub_category) }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(Pageable) }
    it { is_expected.to include_module(Sanitizable) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:name) }
  end

  describe "constants" do
    it { is_expected.to have_constant(:LISTING_ATTRIBUTES) }
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:name).to(:parent_category).allow_nil.with_prefix }
  end

  describe "associations" do
    it { is_expected.to have_many(:sub_categories).class_name("ProductCategory").with_foreign_key(:parent_category_id).inverse_of(:parent_category).dependent(:destroy) }
    it { is_expected.to have_many(:products).inverse_of(:product_category).dependent(:restrict_with_exception) }

    it { is_expected.to belong_to(:parent_category).class_name("ProductCategory").inverse_of(:sub_categories).optional }
  end

  include_examples "apply default scope on created_at:desc"

  describe "validations" do
    describe "#name" do
      let!(:product_category) { create(:product_category) }

      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(255) }
      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:parent_category_id).ignoring_case_sensitivity }
    end
  end

  describe "class methods and scopes" do
    describe ".select_options" do
      let!(:product_category) { create(:product_category, :active) }

      it "should return array of product categories for select list" do
        expect(described_class.select_options).to eq([[product_category.name, product_category.id]])
      end
    end
  end
end
