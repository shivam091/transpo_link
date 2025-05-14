# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/product_category_spec.rb

require "spec_helper"

RSpec.describe ProductCategory, type: :model do
  subject(:product_category) { build(:product_category) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:products_count).of_type(:integer).with_options(default: 0) }
    it { is_expected.to have_db_column(:parent_category_id).of_type(:uuid).with_options(null: true) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:is_active) }
    it { is_expected.to have_db_index(:parent_category_id) }
    it { is_expected.to have_db_index([:name, :parent_category_id]).unique }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:parent_category_id).with_name(:fk_product_categories_parent_category_id_on_product_categories).on_delete(:cascade) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_product_categories_name_presence).with_expression("name IS NOT NULL AND name::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_product_categories_name_length).with_expression("char_length(name::text) <= 255 AND char_length(name::text) >= 2") }
  end
end
