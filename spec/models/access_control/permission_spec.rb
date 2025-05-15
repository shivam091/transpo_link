# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/access_control/permission_spec.rb

require "spec_helper"

RSpec.describe AccessControl::Permission, type: :model do
  subject(:permission) { build(:permission) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:permission) }
  end
end
