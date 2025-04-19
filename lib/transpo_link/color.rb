# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  ##
  # A value object representing a color defined by a hexadecimal code.
  # Provides validation, RGBA extraction, and RGBA-to-HSLA conversion.
  #
  # Supported formats:
  # - #RGB
  # - #RGBA
  # - #RRGGBB
  # - #RRGGBBAA
  #
  # @example
  #   color = TranspoLink::Color.new('#ffcc00')
  #   color.valid?       # => true
  #   color.rgba         # => [255, 204, 0, 255]
  #   color.to_hsl       # => [48, 100, 50]
  #
  class Color
    ##
    # Initializes a new color instance.
    #
    # @param value [String, Color] A hex string (e.g., "#ffcc00") or another Color instance.
    #
    def initialize(value)
      raw_value = value.is_a?(self.class) ? value.to_s : value
      @value = raw_value&.strip&.freeze
    end

    ##
    # Returns the string representation of the color.
    #
    # @return [String] Hex color string (e.g., "#ffcc00").
    #
    def to_s
      @value
    end

    ##
    # Returns a JSON-safe string representation of the color.
    #
    # @param _options [Hash] Ignored.
    #
    # @return [String] JSON-safe hex color string.
    #
    def as_json(_options = nil)
      to_s
    end

    ##
    # Compares this color with another object for equality.
    #
    # @param other [Object] The object to compare.
    #
    # @return [Boolean] True if the other object is a Color with the same value.
    #
    def eql?(other)
      other.is_a?(self.class) && to_s == other.to_s
    end
    alias_method :==, :eql?

    ##
    # Checks whether the color is a valid hexadecimal color code.
    #
    # @return [Boolean] True if valid; false otherwise.
    #
    def valid?
      Regex::HEX_COLOR_CODE_REGEX.match?(@value)
    end

    ##
    # Converts the hex color to its RGBA components.
    #
    # @return [Array<Integer>] Array of [r, g, b, a] (0–255), or empty array if invalid.
    #
    def rgba
      return [] unless valid?

      @rgba ||= Converter.hex_to_rgba(@value)
    end

    ##
    # Converts the color to RGBA, scaling alpha to 0–255.
    #
    # @return [Array<Integer>] Array of [r, g, b, a], where alpha is scaled.
    #
    def rgba_scaled
      rgba.tap { |c| c[3] = (c[3] * 255).round if c[3] }
    end

    ##
    # Converts the color to HSLA (Hue, Saturation, Lightness) with alpha.
    #
    # @return [Array<(Integer, Integer, Integer, Float)>] Array of [h, s, l, a]
    #
    def hsla
      @hsla ||= Converter.rgba_to_hsla(*rgba[0..2])
    end

    ##
    # Converts the color to HSLA, scaling alpha to 0–255.
    #
    # @return [Array<(Integer, Integer, Integer, Integer)>] Array of [h, s, l, a]
    #
    def hsla_scaled
      hsla.tap { |c| c[3] = (c[3] * 255).round if c[3] }
    end

    ##
    # Module for color space conversions between HEX, RGBA, and HSLA.
    #
    module Converter
      extend self

      ##
      # Converts a valid hex string into RGBA components.
      #
      # @param hex [String] Hexadecimal color string (e.g., "#fc0", "#fc0f", "#ffcc00", "#ffcc00ff").
      #
      # @return [Array<(Integer, Integer, Integer, Float)>] Array of [r, g, b, a]
      #
      def hex_to_rgba(hex)
        rgba = case hex.length
               when 4 then hex[1, 3].chars.map { |c| (c * 2).hex } # #RGB
               when 5 then hex[1, 4].chars.map { |c| (c * 2).hex } # #RGBA
               when 7 then hex[1, 6].scan(/../).map(&:hex)         # #RRGGBB
               else        hex[1, 8].scan(/../).map(&:hex)         # #RRGGBBAA
               end
         red, green, blue, alpha = *rgba
         alpha ||= 255

         [red, green, blue, (alpha / 255.0).round(2)]
      end

      ##
      # Converts RGBA components to HSLA values with alpha.
      #
      # @param red [Integer] Red component (0–255)
      # @param green [Integer] Green component (0–255)
      # @param blue [Integer] Blue component (0–255)
      # @param alpha [Float] Alpha component (0.0–1.0)
      #
      # @return [Array<(Integer, Integer, Integer, Float)>] Array of [hue, saturation, lightness, alpha]
      #
      def rgba_to_hsla(red, green, blue, alpha = 1.0)
        red /= 255.0
        green /= 255.0
        blue /= 255.0

        max_channel = [red, green, blue].max
        min_channel = [red, green, blue].min
        delta = max_channel - min_channel

        lightness = (max_channel + min_channel) / 2.0
        hue = saturation = 0.0

        unless delta.zero?
          saturation = lightness >= 0.5 ? delta / (2.0 - max_channel - min_channel) : delta / (max_channel + min_channel)

          hue = case max_channel
                when red   then (green - blue) / delta + (green < blue ? 6 : 0)
                when green then (blue - red) / delta + 2
                when blue  then (red - green) / delta + 4
                end

          hue /= 6.0
        end

        [(hue * 360), (saturation * 100), (lightness * 100)].map(&:round) + [alpha.round(2)]
      end

      ##
      # Converts HSLA values back to RGBA.
      #
      # @param hue [Numeric] Hue (0–360)
      # @param saturation [Numeric] Saturation (0–100)
      # @param lightness [Numeric] Lightness (0–100)
      # @param alpha [Numeric] Alpha (0.0–1.0)
      #
      # @return [Array<(Integer, Integer, Integer, Float)>] Array of [r, g, b, a]
      #
      def hsla_to_rgba(hue, saturation, lightness, alpha = 1.0)
        hue /= 360.0
        saturation /= 100.0
        lightness /= 100.0
        alpha = [[alpha.to_f, 0.0].max, 1.0].min # clamp between 0.0 and 1.0

        if saturation.zero?
          red = green = blue = (lightness * 255).round
        end

        temp2 = if lightness < 0.5
                  lightness * (1.0 + saturation)
                else
                  lightness + saturation - lightness * saturation
                end

        temp1 = 2.0 * lightness - temp2

        red = hue_to_rgb(temp1, temp2, hue + 1.0 / 3)
        green = hue_to_rgb(temp1, temp2, hue)
        blue = hue_to_rgb(temp1, temp2, hue - 1.0 / 3)

        [red, green, blue].map { |channel| (channel * 255).round } + [alpha]
      end

      ##
      # Converts RGBA values to a hexadecimal color string.
      #
      # @param red [Integer] Red component (0–255)
      # @param green [Integer] Green component (0–255)
      # @param blue [Integer] Blue component (0–255)
      # @param alpha [Integer] Alpha component (0–255)
      #
      # @return [String] Hex string (e.g., "#ff00aa" or "#ff00aa80")
      #
      def rgba_to_hex(red, green, blue, alpha = 255)
        components = [red, green, blue]
        components << alpha if alpha < 255

        hex = components.map { |c| c.clamp(0, 255).to_i.to_s(16).rjust(2, "0") }.join

        if (hex.length == 6 || hex.length == 8) && hex.scan(/../).all? { |pair| pair[0] == pair[1] }
          "##{hex.scan(/../).map { |pair| pair[0] }.join}"
        else
          "##{hex}"
        end
      end

      ##
      # Helper method to convert hue into an RGBA component.
      #
      # @param p [Float] Temporary value.
      # @param q [Float] Temporary value.
      # @param hue [Float] Hue (0.0–1.0)
      #
      # @return [Float] Component value (0.0–1.0)
      #
      def hue_to_rgb(p, q, hue)
        hue += 1 if hue < 0
        hue -= 1 if hue > 1

        return p + (q - p) * 6 * hue if hue < 1.0 / 6
        return q if hue < 1.0 / 2
        return p + (q - p) * (2.0 / 3 - hue) * 6 if hue < 2.0 / 3
        p
      end

      private_class_method :hue_to_rgb
    end
  end
end
