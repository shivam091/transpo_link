# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts that the module is included within the class.
#
# ```
# RSpec.describe ModelName, type: :model do
#   it { is_expected.to include_module(ModuleName) }
# end
# ```
RSpec::Matchers.define :include_module do |expected|
  match do
    described_class.included_modules.include?(expected)
  end

  description do
    "include the #{expected} module"
  end

  failure_message do
    "expected #{described_class} to include the #{expected} module"
  end

  failure_message_when_negated do
    "expected #{described_class} not to include the #{expected} module"
  end
end
