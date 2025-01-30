# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for manipulating with links.
#
module LinksHelper
  def link_to(name = nil, options = nil, html_options = nil, &block)
    if html_options&.dig(:class).is_a?(Array)
      html_options[:class] = html_options[:class].compact_blank
    end

    super(name, options, html_options, &block)
  end
end
