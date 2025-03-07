# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts whether the attribute is configured to nullify if it's value is blank
# (are false, empty or contain only whitespace).
#
# ```
# RSpec.describe ModelName, type: :model do
#   it { is_expected.to nullify_if_blank(:email) }
# end
# ```
RSpec::Matchers.define :nullify_if_blank do |attribute|
  match do |record|
    expect(record.class.attributes_to_nullify).to include(attribute)
  end

  description do
    "nullify the #{attribute} attribute if it is blank"
  end

  failure_message do |record|
    "expected #{record.class} to nullify #{attribute} if blank, but it was not included in attributes_to_nullify"
  end

  failure_message_when_negated do |record|
    "expected #{record.class} not to nullify #{attribute} if blank, but it was included in attributes_to_nullify"
  end
end
