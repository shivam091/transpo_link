# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for rendering SVG images.
#
module ImagesHelper
  DEFAULT_SVG_OPTIONS = {height: "24px", width: "24px"}.freeze

  def external_svg_tag(file_name, options = {})
    options = DEFAULT_SVG_OPTIONS.merge(options)

    file_content = File.read(Rails.root.join("app", "assets", "images", file_name))
    doc = Nokogiri::HTML::DocumentFragment.parse(file_content)
    svg = doc.at_css("svg")

    options.each do |attr, value|
      if value.is_a?(Hash)
        value.transform_keys! { |key| "#{attr}-#{key.to_s.dasherize}" }
        value.each { |transformed_key, sub_value| svg[transformed_key] = sub_value }
      else
        svg[attr.to_s] = value
      end
    end

    doc.to_html.html_safe
  end

  def inline_svg_tag(symbol_id, options = {})
    options = DEFAULT_SVG_OPTIONS.merge(options)
    options[:class] = ["icon", "icon-#{symbol_id}", options[:class]].compact.join(" ")

    icon = content_tag(:use, nil, "xlink:href": "#{image_url('svgs/defs.svg')}#icon-#{symbol_id}")

    content_tag(:svg, icon, options)
  end
end
