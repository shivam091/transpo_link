# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module DateTimeHelperSupport
  # Helper to call prettify_* with timezone conversion by default
  def prettify_with_zone(method, value, options = {})
    helper.send(method, value, **options.merge(convert_timezone: true))
  end
end
