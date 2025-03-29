# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Be sure to restart your server when you modify this file.

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  fragment = Loofah.fragment(html_tag)
  element = fragment.children.first

  next html_tag if element.blank? || element["type"] == "hidden"

  element.add_class("is-invalid")
  html_tag = element.to_html

  if %w[input select textarea].include?(element.name)
    attribute = instance.instance_variable_get(:@method_name)
    error_messages = instance.object.errors.full_messages_for(attribute)

    if error_messages.any?
      error_div = "<div class='invalid-feedback'>#{error_messages.to_sentence}</div>"
      html_tag << error_div
    end
  end

  html_tag.html_safe
end
