# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/access_control/module_spec.rb

require "spec_helper"

RSpec.describe AccessControl::Module, type: :model do
  subject(:module) { build(:module) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:label_key).of_type(:string) }
    it { is_expected.to have_db_column(:position).of_type(:integer) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:label_key).unique }
    it { is_expected.to have_db_index(:position).unique }
    it { is_expected.to have_db_index(:is_active) }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_access_control_modules_label_key_presence).with_expression("label_key IS NOT NULL AND label_key::text <> ''::text") }
    it { is_expected.to have_check_constraint(:check_access_control_modules_label_key_length).with_expression("char_length(label_key::text) <= 55") }
    it { is_expected.to have_check_constraint(:check_access_control_modules_position_positive).with_expression("\"position\" > 0") }
    it { is_expected.to have_check_constraint(:check_access_control_modules_position_presence).with_expression("\"position\" IS NOT NULL") }
  end
end
