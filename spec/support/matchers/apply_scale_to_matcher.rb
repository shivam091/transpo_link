# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts whether the attribute is configured to apply scale rounding based on the model's schema.
#
# ```
# RSpec.describe ModelName, type: :model do
#   it { is_expected.to apply_scale_to(:price) }
#   it { is_expected.to apply_scale_to(:discount) }
# end
# ```
RSpec::Matchers.define :apply_scale_to do |attribute|
  match do |record|
    record.class.attributes_to_round.any? { |config| config[:attribute] == attribute }
  end

  description do
    "apply scale rounding to :#{attribute}"
  end

  failure_message do |record|
    "expected #{record.class} to apply scale rounding to :#{attribute}"
  end

  failure_message_when_negated do |record|
    "expected #{record.class} not to apply scale rounding to :#{attribute}"
  end
end
