# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Be sure to restart your server when you modify this file.

# This module creates `PrettyFormBuilder` wrappers around the default `form_with`
# and `form_for` methods.
#
# Example:
#
#   pretty_form_for @user do |form|
#     form.text_field :name
#   end
#
#   pretty_form_with model: @user do |form|
#     form.text_field :name
#   end
module PrettyFormHelper
  def pretty_form_for(record, options = {}, &block)
    options.reverse_merge!(builder: PrettyFormBuilder)

    form_for(record, options, &block)
  end

  def pretty_form_with(options = {}, &block)
    options.reverse_merge!(builder: PrettyFormBuilder)

    form_with(**options, &block)
  end
end

ActiveSupport.on_load(:action_view) do
  include PrettyFormHelper
end
