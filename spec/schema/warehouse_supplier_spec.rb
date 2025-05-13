# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/warehouse_supplier_spec.rb

require "spec_helper"

RSpec.describe WarehouseSupplier, type: :model do
  subject(:warehouse_supplier) { build(:warehouse_supplier) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:warehouse_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:supplier_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:warehouse_id) }
    it { is_expected.to have_db_index(:supplier_id) }
  end

  describe "foreign keys" do
    it { is_expected.to have_foreign_key(:warehouse_id).with_name(:fk_warehouse_suppliers_warehouse_id_on_warehouses).on_delete(:cascade) }
    it { is_expected.to have_foreign_key(:supplier_id).with_name(:fk_warehouse_suppliers_supplier_id_on_users).on_delete(:restrict) }
  end
end
