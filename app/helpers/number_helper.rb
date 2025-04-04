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

  # Converts a number into a formatted measurement unit string.
  #
  # This method formats a given number according to the specified measurement unit,
  # applying rounding, delimiters, and pluralization rules based on I18n translations.
  #
  # @param [Numeric, nil] number The number to be formatted. Returns `nil` if `number` is `nil`.
  # @param [Symbol, String] unit The measurement unit symbol (e.g., `:ft`, `:kg`, `:m`).
  # @param [Hash] options Additional formatting options.
  # @option options [Integer] :precision (2) Number of decimal places to round to.
  # @option options [Boolean] :strip_insignificant_zeros (false) Whether to remove trailing zeros after the decimal point.
  # @option options [String] :delimiter (",") Thousands delimiter.
  # @option options [String] :separator (".") Decimal separator.
  # @option options [String] :format ("%{n} %{u}") String format where `%{n}` is the number and `%{u}` is the unit.
  # @option options [Hash] :units A hash of measurement unit translations with singular (`one`) and plural (`other`) forms.
  #
  # @raise [KeyError] if the given unit is not found in the provided `units` hash.
  #
  # @return [String, nil] The formatted measurement string (e.g., `"1.00 foot"`, `"2.50 metres"`), or `nil` if input is invalid.
  #
  # @example Basic usage with default options
  #   number_to_measurement_unit(1, :ft) #=> "1.00 foot"
  #   number_to_measurement_unit(2, :ft) #=> "2.00 feet"
  #
  # @example Custom separator and delimiter
  #   number_to_measurement_unit(1234.56, :kg, delimiter: ".", separator: ",") #=> "1.234,56 kilogrammes"
  #
  # @example Custom formatting
  #   number_to_measurement_unit(45.678, :kg, format: "%{u} %{n}") #=> "kilogrammes 45.68"
  #
  # @example Handling zero and nil values
  #   number_to_measurement_unit(0, :m)   #=> "0.00 metres"
  #   number_to_measurement_unit(nil, :m) #=> nil
  #
  # @example Handling floating-point numbers and rounding
  #   number_to_measurement_unit(1.9999, :m) #=> "2.00 metres"
  #
  def number_to_measurement_unit(number, unit, options = {})
    return nil if number.nil? || unit.blank?

    i18n_defaults = I18n.t("number.measurement_unit", default: {})
    options = options.deep_symbolize_keys.reverse_merge(i18n_defaults)

    unit_options = options[:units].fetch(unit.to_sym, {})
    unit_key = number.to_f == 1.0 ? :one : :other
    unit_format = unit_options.fetch(unit_key)

    formatted_number = number_to_delimited(number_to_rounded(number, options), options)

    options[:format] % {n: formatted_number, u: unit_format}
  end
end
