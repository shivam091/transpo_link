# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to provide a method to decorate models using presenter classes
#
# This module allows any model to be decorated with a corresponding presenter class.
# The presenter class is inferred by appending "Presenter" to the model's class name.
#
# Example Usage:
# ```ruby
# class Order < ApplicationRecord
#   include Presentable
# end
#
# class OrderPresenter
#   def initialize(order, view_context)
#     @order = order
#     @view_context = view_context
#   end
#
#   # Example method in presenter
#   def formatted_amount
#     @view_context.number_to_currency(@order.amount)
#   end
# end
#
# order = Order.first
# order.decorate(view_context) # Returns an instance of OrderPresenter
# ```
module Presentable

  # Returns an instance of the associated presenter class.
  #
  # @param view_context [ActionView::Base, nil] The view context, typically used for helper methods.
  # @return [Object] An instance of the inferred presenter class.
  #
  # @example Decorating a model instance:
  #   user = User.first
  #   user.decorate(view_context) # Returns an instance of UserPresenter
  def decorate(view_context = nil)
    "#{self.class}Presenter".constantize.new(self, view_context)
  end
end
