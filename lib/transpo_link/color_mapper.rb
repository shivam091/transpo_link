# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  # A utility class for mapping domain-specific keys (such as statuses or tax types)
  # to consistent color codes used throughout the application.
  #
  # This class supports multiple types of mappings (e.g., `status`, `tax_type`, `tracking_method`),
  # each associated with a hash of stringified keys and hex color codes with alpha values.
  #
  # @example Get a color for a status
  #   mapper = TranspoLink::ColorMapper.new(:status)
  #   mapper.for(:approved) # => "#43FF2CFF"
  #
  # @example Get a fallback color if key not found
  #   mapper = TranspoLink::ColorMapper.new(:status)
  #   mapper.for(:unknown) # => "#D3D3D3FF"
  #
  class ColorMapper
    # A frozen hash of all supported color mappings grouped by type.
    #
    # @return [Hash{String=>Hash{String=>String}}] Mapping of types to keyed color codes.
    #
    COLOR_MAPS = {
      status: {
        unapproved:          "#F8D210FF", # Turbo
        draft:               "#D4C5F9FF", # Lavender blue
        submitted:           "#FBCA04FF", # Tangerine yellow
        approved:            "#43FF2CFF", # Harlequin
        cancelled:           "#E57F84FF", # Carissma
        rejected:            "#B60205FF", # Guardsman red
        partially_delivered: "#2FF3E0FF", # Bright turquoise
        fully_delivered:     "#006622FF", # British racing green
        delivered:           "#36EEE0FF", # Turquoise
        pending:             "#BFD4F2FF", # Pale Cornflower Blue
        closed:              "#3D550CFF", # Verdun Green
        on_hold:             "#FBC740FF", # Sunglow
        ordered:             "#5DA9E9FF", # Blue Jeans
      },
      tax_type: {
        exclusive:           "#F26B38FF", # Water leaf
        inclusive:           "#FBCA04FF", # Tangerine yellow
      },
      tracking_method: {
        fifo:                "#2CFFFBFF", # Aqua
        lifo:                "#0C2D48FF", # Cyprus
        average_cost:        "#BFDADCFF", # Iceberg
      }
    }.deep_stringify_keys.freeze

    # Initializes a new ColorMapper for a specific mapping type.
    #
    # @param type [String, Symbol] The mapping category (e.g., `:status`, `:tax_type`, `:tracking_method`)
    #
    def initialize(type)
      @type = type.to_s
    end

    # Retrieves the hex color code for the given key under the current mapping type.
    #
    # @param key [String, Symbol] The lookup key (e.g., `:approved`, `:fifo`, etc.)
    # @return [String] The hex color code with alpha (e.g., "#43FF2CFF"), or fallback ("#D3D3D3FF") if not found.
    #
    def for(key)
      COLOR_MAPS.dig(@type, key.to_s) || "#D3D3D3FF"
    end
  end
end
