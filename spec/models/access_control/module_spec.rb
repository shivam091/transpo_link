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

  describe "associations" do
    it { is_expected.to have_many(:permissions).class_name("AccessControl::Permission").inverse_of(:module).dependent(:restrict_with_exception) }
  end
end
