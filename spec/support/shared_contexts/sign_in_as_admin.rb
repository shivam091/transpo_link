# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_context "sign in as admin" do
  let(:admin) { create(:admin, :active, :confirmed, :with_address) }

  before { sign_in(admin, scope: :user) }

  after { sign_out(admin) }
end
