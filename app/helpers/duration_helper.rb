# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for dealing with duration.
#
module DurationHelper
  def prettify_seconds(seconds, options = {})
    options.reverse_merge!(locale: TranspoLink::I18n.locale, scope: "datetime.units")

    parts = ActiveSupport::Duration.build(seconds).parts

    I18n.with_options(**options) do |locale|
      parts.each.with_object([]) do |(unit, value), duration|
        duration << locale.t(unit.to_s, count: value)
      end
    end.join(", ")
  end
end
