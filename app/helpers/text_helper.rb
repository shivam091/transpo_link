# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TextHelper
  def truncate(text, options = {})
    options = {truncate_at: 30, omission: "..."}.merge(options)

    return text if text.length <= options[:truncate_at]

    stop = text.rindex(options[:omission], options[:truncate_at]) || options[:truncate_at]

    "#{text[0, stop]}#{options[:omission]}"
  end
end
