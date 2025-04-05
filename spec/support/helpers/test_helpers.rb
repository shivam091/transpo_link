# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TestHelpers
  def sort_attributes(html)
    Loofah.fragment(html).tap do |fragment|
      fragment.traverse do |node|
        next unless node.element?

        # Replace attributes with sorted ones in one go
        sorted_attrs = node.attribute_nodes.sort_by(&:name)
        node.attributes.clear
        sorted_attrs.each { |attr| node[attr.name] = attr.value }

        # Strip whitespace inside text nodes
        node.content = node.content.strip if node.text?
      end
    end.to_s.strip
  end
end
