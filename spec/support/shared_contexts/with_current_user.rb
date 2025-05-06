# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_context "with current user" do
  let!(:current_user) { create(:buyer, :confirmed, :active) }

  around do |example|
    previous_user = Current.user
    Current.user = current_user
    example.run
    Current.user = previous_user
  end
end
