# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for manipulating with links.
#
module LinksHelper
  def link_to(name = nil, options = nil, html_options = nil, &block)
    if html_options&.dig(:class).is_a?(Array)
      classes = html_options[:class].compact_blank
      classes.empty? ? html_options.delete(:class) : html_options[:class] = classes
    end

    super(name, options, html_options, &block)
  end
end
