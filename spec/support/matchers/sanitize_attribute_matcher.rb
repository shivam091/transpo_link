# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts whether an attribute is configured to be sanitized and whether HTML is
# allowed or stripped.
#
# ```
# RSpec.describe ModelName, type: :model do
#   # Ensures that the name attribute is sanitized (HTML will be stripped by default).
#   it { is_expected.to sanitize_attribute(:name) }
#
#   # Ensures that HTML is allowed for the bio attribute.
#   it { is_expected.to sanitize_attribute(:bio).allow_html } # or allow_html(true)
# end
# ```
RSpec::Matchers.define :sanitize_attribute do |attribute|
  match do |record|
    matched_attribute = record.class.sanitizable_attributes.find { _1[:attribute] == attribute }
    matched_attribute && (!instance_variable_defined?(:@allow_html) || matched_attribute[:allow_html] == @allow_html)
  end

  chain :allow_html do |value = true|
    @allow_html = value
  end

  description do
    description = "sanitize the :#{attribute}"

    if instance_variable_defined?(:@allow_html)
      description += @allow_html ? " allowing HTML" : " stripping all HTML"
    end

    description
  end

  failure_message do |record|
    failure_message = "expected #{record.class} to sanitize :#{attribute}"

    if instance_variable_defined?(:@allow_html)
      failure_message += @allow_html ? " allowing HTML" : " stripping all HTML"
      failure_message += ", but it was not configured correctly"
    end

    failure_message
  end

  failure_message_when_negated do |record|
    failure_message = "expected #{record.class} not to sanitize :#{attribute}"

    if instance_variable_defined?(:@allow_html)
      failure_message += @allow_html ? " allowing HTML" : " stripping all HTML"
      failure_message += ", but it was configured to do so"
    end

    failure_message
  end
end
