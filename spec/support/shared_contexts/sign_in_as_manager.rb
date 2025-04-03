# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_context "sign in as manager" do
  let(:manager) { create(:manager, :active, :confirmed) }

  before { sign_in(manager, scope: :user) }

  after { sign_out(manager) }
end
