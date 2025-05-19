# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_context "with permissions" do |module_key:, action_keys:|
  before do
    Array(action_keys).each do |action_key|
      grant_permission!(current_user, module_key, action_key)
    end
  end
end
