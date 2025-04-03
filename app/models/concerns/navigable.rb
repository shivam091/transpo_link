# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# This module provides navigation capabilities for ActiveRecord models.
# It allows retrieving the **next** and **previous** records based on the model’s
# **default scope** or a custom column.
#
# @example Usage in an ActiveRecord model:
#   class Product < ApplicationRecord
#     include Navigable
#
#     default_scope { order(created_at: :asc) }
#   end
#
#   product = Product.find(uuid)
#   product.previous_record # => Returns the previous Product based on created_at
#   product.next_record     # => Returns the next Product based on created_at
#
# @note
# - If no **default scope** is found, it will fall back to sorting by `created_at:asc`.
# - If there’s no **previous** or **next** record, it will return `nil`.
# - The ordering column and direction can be overridden at the class level.
#
# @example Custom ordering:
#   class Order < ApplicationRecord
#     include Navigable
#
#     self.ordering_column = :order_number
#     self.ordering_direction = :asc
#   end
#
#   order = Order.find(uuid)
#   order.previous_record # => Returns the previous Order based on order_number
#   order.next_record     # => Returns the next Order based on order_number
#
module Navigable
  extend ActiveSupport::Concern

  included do
    # The column used for ordering records (default: :created_at)
    class_attribute :ordering_column, default: :created_at

    # The direction used for ordering records (default: :desc)
    class_attribute :ordering_direction, default: :desc

    # Returns the next record based on the defined ordering column and direction.
    #
    # @return [ActiveRecord::Base, nil] the next record or nil if there is none
    def next_record
      self.class.unscoped
        .where(next_record_condition)
        .reorder(next_record_ordering_clause)
        .limit(1)
        .first
    end

    # Returns the previous record based on the defined ordering column and direction.
    #
    # @return [ActiveRecord::Base, nil] the previous record or nil if there is none
    def previous_record
      self.class.unscoped
        .where(previous_record_condition)
        .reorder(previous_record_ordering_clause)
        .limit(1)
        .first
    end

    # Sets the default scope for ordering if none exists.
    default_scope { default_navigable_scope }
  end

  class_methods do
    # Defines the default scope for navigation if not explicitly set.
    #
    # @return [ActiveRecord::Relation] ordered query based on the defined column and direction.
    def default_navigable_scope
      order(arel_table[ordering_column].send(ordering_direction))
    end
  end

  private

  # Returns the Arel table for the model.
  #
  # @return [Arel::Table] the model's Arel table
  def arel_table
    self.class.arel_table
  end

  # Reverses the ordering direction (asc -> desc, desc -> asc).
  #
  # @return [Symbol] the reversed direction
  def reverse_ordering_direction
    ordering_direction == :asc ? :desc : :asc
  end

  # Constructs the condition for finding the next record.
  #
  # @return [Arel::Nodes::Node] the Arel condition for filtering next records
  def next_record_condition
    arel_table[ordering_column].send(condition_operator(:next), self[ordering_column])
  end

  # Constructs the ordering clause for the next record.
  #
  # @return [Arel::Nodes::Ordering] the ordering clause for finding the next record
  def next_record_ordering_clause
    arel_table[ordering_column].send(ordering_direction)
  end

  # Constructs the condition for finding the previous record.
  #
  # @return [Arel::Nodes::Node] the Arel condition for filtering previous records
  def previous_record_condition
    arel_table[ordering_column].send(condition_operator(:previous), self[ordering_column])
  end

  # Constructs the ordering clause for the previous record.
  #
  # @return [Arel::Nodes::Ordering] the ordering clause for finding the previous record
  def previous_record_ordering_clause
    arel_table[ordering_column].send(reverse_ordering_direction)
  end

  # Determines the condition operator based on navigation type.
  #
  # @param type [Symbol] :next or :previous
  # @return [Symbol] :gt (greater than) or :lt (less than)
  def condition_operator(type)
    case type
    when :next     then ordering_direction == :asc ? :gt : :lt
    when :previous then ordering_direction == :asc ? :lt : :gt
    end
  end
end
