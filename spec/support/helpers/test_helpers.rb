# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TestHelpers
  def sort_attributes(doc)
    doc.dup.traverse do |node|
      next unless node.is_a?(Nokogiri::XML::Element)

      sorted_attributes = node.attribute_nodes.sort_by(&:name)
      sorted_attributes.each do |attr|
        node.delete(attr.name)
        node[attr.name] = attr.value
      end
    end
    doc
  end
end
