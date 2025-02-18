# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Be sure to restart your server when you modify this file.

class PrettyFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    options[:class] = append_class(options[:class], "form-control")
    super(attribute, options)
  end

  def select(attribute, choices = nil, options = {}, html_options = {}, &block)
    html_options[:class] = append_class(html_options[:class], "form-select")
    super(attribute, choices, options, html_options, &block)
  end

  private

  # Append new class to existing classes without duplication
  def append_class(existing_classes, new_class)
    [existing_classes, new_class].compact.join(' ').split.uniq.join(' ')
  end
end
