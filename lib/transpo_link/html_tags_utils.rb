# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: false -*-
# -*- warn_indent: true -*-

module TranspoLink
  # This module provides utility methods for handling HTML tags, specifically resolving
  # safe HTML tags and returning a default fallback when an invalid tag is provided.
  #
  # This module is useful for ensuring that HTML tags used within the application are
  # among a predefined set of "safe" tags. If an invalid tag is provided, the module
  # defaults to `:span` to ensure safe rendering.
  #
  # @example Using `resolve_html_tag`
  #   include TranspoLink::HtmlTagsUtils
  #
  #   resolve_html_tag(:div)   # => :div
  #   resolve_html_tag(:h1)    # => :span (default)
  #
  module HtmlTagsUtils
    # A constant list of safe HTML tags that are allowed in the application.
    # This list is frozen to ensure immutability.
    #
    # @return [Array<Symbol>] An array of allowed HTML tag symbols.
    HTML_SAFE_TAGS = %i[span a div button strong small].freeze

    # Resolves the provided HTML tag and returns it if it is included in the list
    # of safe tags, otherwise defaults to `:span`.
    #
    # @param html_tag [Symbol, String] The HTML tag to be resolved.
    #   It will be converted to a symbol and checked against `HTML_SAFE_TAGS`.
    #
    # @return [Symbol] The resolved HTML tag, or `:span` if the tag is not safe.
    #   Returns `nil` if the input is nil or empty.
    #
    # @example Resolving valid tags
    #   resolve_html_tag(:div)   # => :div
    #   resolve_html_tag(:button) # => :button
    #
    # @example Resolving invalid tags
    #   resolve_html_tag(:h1)    # => :span
    #
    def resolve_html_tag(html_tag)
      return unless html_tag

      tag = html_tag.to_s.strip.downcase.to_sym
      HTML_SAFE_TAGS.include?(tag) ? tag : :span
    end
  end
end
