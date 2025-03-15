# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TextHelper
  def word_wrap(text, options = {})
    options = {wrap_length: 80, seperator: "<br/>"}.merge(options)

    # Return the text if it's shorter than the line width
    return text if text.length <= options[:wrap_length]

    # Break text into words
    wrapped_text = text.scan(/\S.{0,#{options[:wrap_length] - 1}}\S(?=\s|$)|\S+/).join(" ")
    # Break lines at the desired width and insert separator
    wrapped_text = wrapped_text.scan(/.{1,#{options[:wrap_length]}}/).join(options[:seperator])

    wrapped_text
  end

  def truncate(text, options = {})
    options = {truncate_at: 30, omission: "..."}.merge(options)

    return text if text.length <= options[:truncate_at]

    stop = text.rindex(options[:omission], options[:truncate_at]) || options[:truncate_at]

    "#{text[0, stop]}#{options[:omission]}"
  end
end
