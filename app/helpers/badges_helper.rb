# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for rendering theme-aware, color-customizable badge elements.
#
# These badges support various options like shape, color, icons, and accessibility,
# and adapt to both light and dark themes using CSS variables.
#
# @example Basic usage
#   badge_tag("Approved", color: "#ffcc00")
#
# @example With shape
#   badge_tag("Pending", color: "#ffcc00", shape: :rounded)
#
# @example With icon
#   badge_tag("Info", color: "#ffcc00", icon: "info")
#
# @example Icon only
#   badge_tag("Warning", color: "#ffcc00", icon: "alert", icon_only: true)
#
# @example As a link
#   badge_tag("Click me", {color: "#008000"}, {href: some_path})
#
# @example With custom class and block content
#   badge_tag({color: "#008000"}, {class: "my-badge"}) do
#     "Success"
#   end
#
module BadgesHelper
  include TranspoLink::HtmlTagsUtils

  ##
  # Maps supported badge shapes to their corresponding CSS classes.
  #
  # @return [Hash<Symbol, String>] The shape to class mapping.
  #
  SHAPE_CLASSES = {
    rounded: "rounded-pill",
    square: "square-pill"
  }.tap { |hash| hash.default = hash.fetch(:square) }.freeze

  ##
  # Base badge class used in all badge elements.
  #
  # @return [Array<String>] List of base badge CSS classes.
  #
  BADGE_CLASSES = %w[badge].freeze

  ##
  # Renders a badge element with text, color, optional icon, and various configuration options.
  #
  # Can be used with either direct content or block form for more complex rendering.
  #
  # @overload badge_tag(text, options = {}, html_options = {})
  #   @param text [String] The content of the badge.
  #   @param options [Hash] Options for rendering.
  #   @option options [String, TranspoLink::Color] :color Color value or `TranspoLink::Color` instance.
  #   @option options [Symbol] :shape The shape of the badge (`:rounded`, `:square`).
  #   @option options [String] :icon Icon name to display before the text.
  #   @option options [Boolean] :icon_only Whether to show only the icon (with accessibility labels).
  #   @param html_options [Hash] Additional HTML options passed to the tag.
  #
  # @overload badge_tag(options = {}, html_options = {}, &block)
  #   @yield The content block for the badge.
  #   @yieldparam [] none
  #   @param options [Hash] Options for rendering.
  #   @param html_options [Hash] Additional HTML options passed to the tag.
  #
  # @return [String] HTML-safe string for the badge.
  #
  def badge_tag(*args, &block)
    if block_given?
      build_badge_tag(capture(&block), *args)
    else
      build_badge_tag(*args)
    end
  end

  private

  ##
  # Internal method to construct a styled badge element.
  #
  # @param content [String] The content to render inside the badge.
  # @param options [Hash] Options for badge behavior (color, icon, etc.).
  # @param html_options [Hash] Additional attributes for the HTML tag.
  # @option options [String, TranspoLink::Color] :color The color for the badge background.
  # @option options [Symbol] :shape The shape class (`:rounded`, `:square`).
  # @option options [String] :icon Optional icon name to include before content.
  # @option options [Boolean] :icon_only If true, renders only the icon with `aria-label`.
  # @option html_options [String] :tag Optional HTML tag to override (default resolved).
  # @option html_options [String] :href If present, renders as `<a>` tag.
  #
  # @return [String] HTML-safe badge string.
  #
  def build_badge_tag(content, options = {}, html_options = {}, &block)
    shape_class = SHAPE_CLASSES[options.fetch(:shape, SHAPE_CLASSES.default)]
    icon_only = options[:icon_only]

    color_obj = options[:color].is_a?(TranspoLink::Color) ? options[:color] : TranspoLink::Color.new(options[:color])
    red, green, blue = color_obj.rgba
    hue, saturation, lightness = color_obj.hsla

    styles = [
      "--label-r: #{red}",
      "--label-g: #{green}",
      "--label-b: #{blue}",
      "--label-h: #{hue}",
      "--label-s: #{saturation}",
      "--label-l: #{lightness}"
    ].join(";")

    html_options = html_options.merge(
      class: [*BADGE_CLASSES, shape_class, *Array(html_options[:class])],
      style: styles
    )

    if icon_only
      html_options["aria-label"] = content
      html_options["role"] = "img"
    end

    if options[:icon]
      icon = sprite_icon(options[:icon], class: class_names("me-1": !icon_only))
      content = icon_only ? icon : safe_join([icon, content])
    end

    html_tag = html_options[:href] ? :a : (resolve_html_tag(html_options[:tag]) || :span)
    content_tag(html_tag, content, html_options)
  end
end
