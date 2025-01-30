# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts that the route requires authentication before accessing.
#
# ```
# RSpec.describe "Users", type: :request do
#   subject { get users_path }
#
#   it { is_expected.to require_login }
# end
# ```
RSpec::Matchers.define :require_login do
  match do |controller|
    expect(controller).to redirect_to(new_user_session_path)
  end

  description do
    "require authentication before accessing the route"
  end

  failure_message do |controller|
    "expected to require login but did not"
  end

  failure_message_when_negated do |controller|
    "expected not to require login but did"
  end
end
