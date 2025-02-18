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
    normalize_html(actual) == normalize_html(expected)
  end

  description do
    "asserts that the expected HTML matches with actual HTML"
  end

  failure_message do |actual|
    "expected '#{normalize_html(expected)}' to match '#{normalize_html(actual)}'"
  end

  failure_message_when_negated do |actual|
    "expected '#{normalize_html(expected)}' not to match '#{normalize_html(actual)}'"
  end

  private

  # Helper method to normalize HTML.
  def normalize_html(html)
    return "" unless html

    doc = Nokogiri::HTML.fragment(html)
    doc.traverse { |node| node.content = node.content.strip if node.text? }
    sort_attributes(doc).to_xhtml.gsub(/\s+/, " ").strip
  end
end
