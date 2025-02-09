# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts that the model has a valid factory.
#
# ```
# RSpec.describe ModelName, type: :model do
#   it { is_expected.to have_a_valid_factory(factory_name, *traits, **associations) }
# end
# ```
RSpec::Matchers.define :have_a_valid_factory do |factory_name|
  chain :with_associations do |associations|
    @associations = associations
  end

  chain :with_traits do |traits|
    @traits = traits
  end

  match do
    factory = (factory_name || described_class.table_name.singularize.to_sym)

    associations = @associations || {}
    traits = @traits || []

    FactoryBot.build(factory, *traits, **associations)
  end

  description do
    "have valid factory"
  end

  failure_message do
    "expected #{described_class} to have valid factory"
  end

  failure_message_when_negated do
    "expected #{described_class} not to have valid factory"
  end
end
