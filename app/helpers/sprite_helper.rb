# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Helper module to render SVG icons from a sprite sheet (`sprite.svg`)
#
# This module provides a convenient helper method to include SVG icons
# using the `<use>` tag referencing a sprite file. It supports customization
# of icon attributes such as height, width, class names, IDs, and data attributes.
#
# @example Basic usage
#   <%= sprite_icon("truck") %>
#
# @example With additional HTML options
#   <%= sprite_icon("truck", class: "text-blue-500", id: "truck-icon") %>
#
#   # Renders:
#   # <svg class="icon icon-truck text-blue-500" id="truck-icon" height="24px" width="24px">
#   #   <use href="/assets/sprite.svg#truck"></use>
#   # </svg>
#
module SpriteHelper
  # Default options for rendering SVG icons.
  #
  # Includes default height and width.
  #
  # @return [Hash{Symbol=>String}]
  DEFAULT_SPRITE_OPTIONS = {
    height: "24px",
    width: "24px"
  }.freeze

  # Renders an SVG icon referencing the sprite sheet.
  #
  # @param name [String] The icon name used in the `<use>` reference,
  #   which should match an `id` in `sprite.svg`.
  # @param options [Hash] Additional HTML attributes for the `<svg>` element.
  #   These may include:
  #   - `:class` [String] Additional CSS classes
  #   - `:id` [String] An ID for the SVG element
  #   - `:data` [Hash] Custom data attributes (e.g., `data: { toggle: "modal" }`)
  #   - `:height` [String] Override default height
  #   - `:width` [String] Override default width
  #
  # @return [ActiveSupport::SafeBuffer] The generated HTML-safe SVG markup
  def sprite_icon(name, options = {})
    # Merge provided options with default dimensions
    options = DEFAULT_SPRITE_OPTIONS.merge(options)

    # Add semantic icon classes (e.g., "icon icon-truck")
    options[:class] = ["icon", "icon-#{name}", options[:class]].compact.join(" ")

    # Build the <use> tag with sprite reference
    icon = tag.use(href: "#{image_url('sprite.svg')}##{name}")

    # Return the full <svg> tag with nested <use>
    tag.svg(icon, **options)
  end
end
