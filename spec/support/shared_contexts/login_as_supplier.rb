# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_context "login as supplier" do
  let(:supplier) { create(:supplier, :active, :confirmed) }

  before do
    sign_in(supplier)
  end

  after do
    sign_out(supplier)
  end
end
