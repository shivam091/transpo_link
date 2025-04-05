# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Asserts that the expected HTML matches with actual HTML.
#
# ```
# RSpec.describe ModelName, type: :model do
#   it { expect(actual_html).to match_html(expected_html) }
# end
# ```
RSpec::Matchers.define :match_html do |expected|
  match do |actual|
    normalize_html(expected) == normalize_html(actual)
  end

  description do
    "asserts that the expected HTML matches with actual HTML"
  end

  failure_message do |actual|
    "expected '#{normalize_html(actual)}' to match '#{normalize_html(expected)}'"
  end

  failure_message_when_negated do |actual|
    "expected '#{normalize_html(actual)}' not to match '#{normalize_html(expected)}'"
  end

  private

  # Helper method to normalize HTML.
  def normalize_html(html)
    return "" unless html

    # Loofah sanitizes and normalizes HTML
    sanitized_html = Loofah.fragment(html).scrub!(:strip).to_s.strip

    # Sort attributes for consistent comparison
    sort_attributes(sanitized_html).gsub(/\s+/, " ").strip!
  end
end
