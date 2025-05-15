# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/access_control/action_spec.rb

require "spec_helper"

RSpec.describe AccessControl::Action, type: :model do
  subject(:action) { build(:action) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:action) }
  end

  describe "associations" do
    it { is_expected.to have_many(:permissions).class_name("AccessControl::Permission").inverse_of(:action).dependent(:restrict_with_exception) }
  end
end
