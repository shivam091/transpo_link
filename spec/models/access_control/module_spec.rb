# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/access_control/module_spec.rb

require "spec_helper"

RSpec.describe AccessControl::Module, type: :model do
  subject(:module) { build(:module) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:module) }
  end

  describe "normalized attributes" do
    it { is_expected.to normalize(:label_key).from("  CREATE  ").to("create") }
  end

  describe "validations" do
    describe "#label_key" do
      it { is_expected.to validate_presence_of(:label_key) }
      it { is_expected.to validate_uniqueness_of(:label_key).ignoring_case_sensitivity }
      it { is_expected.to validate_length_of(:label_key).is_at_most(55) }
    end

    describe "#position" do
      it { is_expected.to validate_presence_of(:position) }
      it { is_expected.to validate_uniqueness_of(:position).with_message("is already set for other module") }
      it { is_expected.to validate_numericality_of(:position).is_greater_than(0).only_integer }
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:permissions).class_name("AccessControl::Permission").inverse_of(:module).dependent(:restrict_with_exception) }
  end
end
