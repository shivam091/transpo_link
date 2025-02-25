# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# NumberHelper provides formatting utilities for numbers, including converting a
# number to an angle representation with a degree (°) symbol.
#
# This module leverages `ActiveSupport::NumberHelper` for precise number formatting
# and allows customization via options or I18n translations.
module NumberHelper
  include ActiveSupport::NumberHelper

  ##
  # Converts a given number to a formatted angle representation with a degree (°) symbol.
  #
  # @param number [Numeric] The number to be formatted as an angle.
  # @param options [Hash] A hash of formatting options.
  #   Available options:
  #   - `:precision` [Integer, nil] - Number of decimal places to round (default: nil, uses I18n default).
  #   - `:strip_insignificant_zeros` [Boolean] - Removes trailing zeros if true (default: true).
  #   - `:delimiter` [String] - Thousands delimiter (default: ",").
  #   - `:separator` [String] - Decimal separator (default: ".").
  #   - `:format` [String] - String format, where "%{n}" represents the formatted number (default: "%{n}°").
  #
  # @return [String, nil] The formatted angle as a string, or nil if the number is nil.
  #
  # @example
  #   number_to_angle(45.6789)                # => "45.68°"
  #   number_to_angle(90, precision: 0)       # => "90°"
  #   number_to_angle(12.345, format: "%{n} degrees") # => "12.35 degrees"
  #
  def number_to_angle(number, options = {})
    return nil if number.nil?

    options.symbolize_keys!

    i18n_defaults = I18n.t("number.angle", default: {})
    options = options.deep_symbolize_keys.reverse_merge(i18n_defaults)

    options[:format] % {n: number_to_rounded(number, options)}
  end
end
