# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/schema/role_spec.rb

require "spec_helper"

RSpec.describe Role, type: :model do
  subject(:role) { build(:admin_role) }

  describe "attributes" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:name).unique }
  end

  describe "check constraints" do
    it { is_expected.to have_check_constraint(:check_roles_name_length).with_expression("char_length(name::text) <= 55 AND char_length(name::text) >= 2") }
    it { is_expected.to have_check_constraint(:check_roles_name_presence).with_expression("name IS NOT NULL AND name::text <> ''::text") }
  end
end
