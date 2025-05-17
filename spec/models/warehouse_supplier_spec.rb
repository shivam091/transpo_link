# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/warehouse_supplier_spec.rb

require "spec_helper"

RSpec.describe WarehouseSupplier, type: :model do
  subject(:warehouse_supplier) { build(:warehouse_supplier) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:warehouse_supplier) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:warehouse).inverse_of(:warehouse_suppliers).touch }
    it { is_expected.to belong_to(:supplier).inverse_of(:warehouse_suppliers).class_name("User") }
  end
end
