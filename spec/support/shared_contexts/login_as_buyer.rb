# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_context "login as buyer" do
  let(:buyer) { create(:buyer, :active, :confirmed, :with_address) }

  before do
    sign_in(buyer)
  end

  after do
    sign_out(buyer)
  end
end
