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
    sanitizable_attrs = record.class.sanitizable_attributes
    matched_attribute = sanitizable_attrs.find { |attr| attr[:attribute] == attribute }

    return false unless matched_attribute
    return matched_attribute[:allow_html] == @allow_html if instance_variable_defined?(:@allow_html)
    true
  end

  chain :allow_html do |value = true|
    @allow_html = value
  end

  description do
    desc = "sanitize the :#{attribute}"
    if instance_variable_defined?(:@allow_html)
      desc += @allow_html ? " allowing HTML" : " stripping all HTML"
    end

    desc
  end

  failure_message do |record|
    "expected #{record.class} to sanitize :#{attribute} with allow_html=#{@allow_html}, but it was not configured correctly"
  end

  failure_message_when_negated do |record|
    "expected #{record.class} not to sanitize :#{attribute} with allow_html=#{@allow_html}, but it was configured to do so"
  end
end
