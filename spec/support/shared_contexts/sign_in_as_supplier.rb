# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_context "sign in as supplier" do
  let(:supplier) { create(:supplier, :active, :confirmed, :with_address) }

  before { sign_in(supplier) }

  after { sign_out(supplier) }
end
