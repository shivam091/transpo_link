# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_context "sign in as buyer" do
  let(:buyer) { create(:buyer, :active, :confirmed, :with_address) }

  before { sign_in(buyer, scope: :user) }

  after { sign_out(buyer) }
end
