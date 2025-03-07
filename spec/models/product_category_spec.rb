# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/product_category_spec.rb

require "spec_helper"

RSpec.describe ProductCategory, type: :model do
  subject { create(:product_category) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:product_category) }
    it { is_expected.to have_a_valid_factory(:product_sub_category) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:products_count).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:parent_category_id).of_type(:uuid).with_options(null: true) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:is_active) }
    it { is_expected.to have_db_index(:parent_category_id) }
    it { is_expected.to have_db_index([:name, :parent_category_id]).unique(true) }

    it { is_expected.to have_foreign_key(:parent_category_id).with_name(:fk_product_categories_parent_category_id_on_product_categories).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_product_categories_name_presence).with_expression("name IS NOT NULL AND name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_product_categories_name_length).with_expression("char_length(name::text) <= 255 AND char_length(name::text) >= 2") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sortable) }
    it { is_expected.to include_module(Toggleable) }
    it { is_expected.to include_module(Pageable) }
  end

  describe "default values" do
    it "should set false as default value for #is_active" do
      expect(subject.is_active).to be_falsy
    end
  end

  describe "delegates" do
    it { is_expected.to delegate_method(:name).to(:parent_category).allow_nil.with_prefix }
  end

  describe "associations" do
    it { is_expected.to have_many(:sub_categories).class_name("ProductCategory").with_foreign_key(:parent_category_id).inverse_of(:parent_category).dependent(:destroy) }

    it { is_expected.to belong_to(:parent_category).class_name("ProductCategory").inverse_of(:sub_categories).optional }
  end

  include_examples "apply default scope on created_at:desc"

  describe "validations" do
    describe "#name" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(255) }
      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:parent_category_id).case_insensitive }
    end
  end

  describe "class methods" do
    describe ".select_options" do
      it "should return array of product categories for select list" do
        product_category = create(:product_category, :active)

        expect(described_class.select_options).to eq([[product_category.name, product_category.id]])
      end
    end
  end
end
