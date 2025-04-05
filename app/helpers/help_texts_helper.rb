# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# HelpTextsHelper provides utility methods for rendering help text elements
# in your forms or UI components in a standardized format.
#
# It allows rendering inline help content using a tag like `<small>`,
# with Bootstrap-style "text-muted" styling.
#
# @example Inline usage:
#   <%= help_text("Enter your full name.") %>
#
# @example Block usage:
#   <%= help_text do %>
#     This is a longer help text with <strong>HTML</strong>.
#   <% end %>
#
module HelpTextsHelper
  ##
  # Renders a help text element using the specified HTML tag (default: :small).
  # Accepts either a direct string or a block for more complex content.
  #
  # @overload help_text(help_text, help_tag = :small)
  #   @param help_text [String] The text to render inside the help element.
  #   @param help_tag [Symbol] The HTML tag to use (default: :small).
  #   @return [String, nil] The rendered HTML element or nil if no text is provided.
  #
  # @overload help_text(&block)
  #   @yieldreturn [String] The content to be rendered as help text.
  #   @return [String, nil] The rendered HTML element or nil if content is blank.
  #
  def help_text(*args, &block)
    if block_given?
      build_help_text(capture(&block), *args)
    else
      build_help_text(*args)
    end
  end

  private

  ##
  # Internal helper to build the help text tag.
  #
  # @param help_text [String] The content to wrap.
  # @param help_tag [Symbol] The HTML tag to use (default: :small).
  # @return [String, nil] A tag-safe HTML string or nil if help_text is blank.
  #
  def build_help_text(help_text, help_tag = :small)
    return unless help_text.present?

    tag.send(help_tag, help_text, class: "form-text text-muted")
  end
end
