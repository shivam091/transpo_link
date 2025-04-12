# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Be sure to restart your server when you modify this file.

class PrettyFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    if options.delete(:static)
      options.tap do |option|
        option[:readonly] = true
        option[:disabled] = true
        option[:class] = append_class(options[:class], "form-control-plaintext")
      end
    else
      options[:class] = append_class(options[:class], "form-control")
    end
    super(attribute, options)
  end

  def text_area(attribute, options = {})
    options[:class] = append_class(options[:class], "form-control")
    super(attribute, options)
  end

  def number_field(attribute, options = {})
    options[:class] = append_class(options[:class], "form-control")
    super(attribute, options)
  end

  def range_field(attribute, options = {})
    options[:class] = append_class(options[:class], "form-range")
    super(attribute, options)
  end

  def password_field(attribute, options = {})
    options[:class] = append_class(options[:class], "form-control")
    super(attribute, options)
  end

  def date_field(attribute, options = {})
    options[:class] = append_class(options[:class], "form-control")
    super(attribute, options)
  end

  def select(attribute, choices = nil, options = {}, html_options = {}, &block)
    html_options[:class] = append_class(html_options[:class], "form-select")
    super(attribute, choices, options, html_options, &block)
  end

  def radio_button(attribute, tag_value, options = {})
    options[:class] = append_class(options[:class], "form-check-input")
    super(attribute, tag_value, options)
  end

  def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
    options[:class] = append_class(options[:class], "form-check-input")
    super(attribute, options, checked_value, unchecked_value)
  end

  def measurement_unit_select(attribute, options = {}, html_options = {})
    category = options[:category]
    selected_value = options.fetch(:selected, @object&.send(attribute))

    units = Unit.select_options(category).map do |category, units|
      [
        I18n.t(category, scope: "measurement_units.categories"),
        units.map do |unit|
          [I18n.t(unit.symbol, scope: "measurement_units.sub_categories"), unit.id]
        end
      ]
    end.to_h

    select_options = if category
      @template.options_for_select(units.values.flatten(1), selected_value)
    else
      @template.grouped_options_for_select(units, selected_value)
    end

    select(attribute, select_options, options, html_options)
  end

  private

  # Append new class to existing classes without duplication
  def append_class(existing_classes, new_class)
    [existing_classes, new_class].compact.join(" ").split.uniq.join(" ")
  end
end
