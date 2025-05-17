# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/warehouse_manager_spec.rb

require "spec_helper"

RSpec.describe WarehouseManager, type: :model do
  subject(:warehouse_manager) { build(:warehouse_manager) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:warehouse_manager) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:warehouse).inverse_of(:warehouse_managers).touch }
    it { is_expected.to belong_to(:manager).inverse_of(:warehouse_managers).class_name("User") }
  end
end
