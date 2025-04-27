# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Module that enforces scale on decimal attributes before validation.
#
# This module can be included in any ActiveRecord model to ensure that decimal
# attributes are rounded to the correct scale before saving the record.
#
# Example usage:
#
#   class Product < ApplicationRecord
#     include ScaleEnforcer
#
#     # Automatically rounds the `price` and `discount` attributes to their
#     # respective scales before saving.
#     scale_attributes :price, :discount
#   end
#
# In this example, the `price` and `discount` attributes will be rounded according
# to the scale defined in the database schema for the corresponding columns.
#
# @example Applying scale before validation
#   product = Product.new(price: 19.995, discount: 12.345)
#   product.valid? # rounds the `price` to 20.0 and `discount` to 12.35
module ScaleEnforcer
  extend ActiveSupport::Concern

  included do
    # Class attribute to store the list of attributes that need to be rounded
    # along with their corresponding scale.
    class_attribute :attributes_to_round, instance_writer: false, default: []

    # Callback to apply scale to the decimal attributes before validation.
    before_validation :apply_scale
  end

  class_methods do
    # Configures which attributes should be scaled and rounded before validation.
    #
    # @param [Array<Symbol>] attributes List of attribute names that should be rounded.
    #
    # @example
    #   class MyModel < ApplicationRecord
    #     include ScaleEnforcer
    #
    #     scale_attributes :price, :discount
    #   end
    #   This will ensure that the `price` and `discount` attributes are rounded
    #   according to their defined scale in the database schema.
    #
    # @raise [ArgumentError] if the column is not of type :decimal.
    def scale_attributes(*attributes)
      attributes.each do |attribute|
        column = columns_hash[attribute.to_s]

        # Only process decimal columns
        if decimal_column?(column)
          self.attributes_to_round << {attribute: attribute, scale: column.scale}
        else
          raise ArgumentError, "Column #{attribute} must be of type :decimal"
        end
      end
    end

    private

    # Helper method to check if the given column is of type :decimal.
    #
    # @param [ActiveRecord::ConnectionAdapters::Column] column The column to check.
    # @return [Boolean] True if the column is of type :decimal, false otherwise.
    def decimal_column?(column)
      column && column.type == :decimal
    end
  end

  private

  # Applies the scale to each of the configured attributes.
  #
  # This method rounds each attribute to the configured scale before validation.
  # If the value is nil or empty, it skips the rounding. If the value is a valid
  # number, it is rounded according to the scale defined in the model schema.
  # Rounding is done using `BigDecimal::ROUND_HALF_UP` mode.
  #
  # @example Rounding behavior for different attributes
  #   product = Product.new(price: 19.995, discount: 12.345)
  #   product.valid?
  #   # Expected: price = 20.0, discount = 12.35
  #
  # @see BigDecimal#round for more details on rounding modes.
  def apply_scale
    self.class.attributes_to_round.each do |config|
      attribute, scale = config.values_at(:attribute, :scale)
      value = self[attribute]

      # Skip if the value is nil or blank
      next if value.nil? || value.to_s.strip.empty?

      # Round the value to the specified scale with ROUND_HALF_UP rounding mode
      self[attribute] = BigDecimal(value.to_s).round(scale, :half_up)
    end
  end
end
