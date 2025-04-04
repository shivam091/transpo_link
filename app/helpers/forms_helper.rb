# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods to format & render error messages.
#
module FormsHelper
  def form_errors(record)
    if record.errors.any?
      headline = t(:header, scope: "activerecord.errors.template", count: record.errors.count)
      tag.div(id: "error-explanation") do
        tag.h6(headline) <<
          tag.dl do
            record.errors.full_messages.map do |message|
              tag.dd do
                concat(external_svg_tag("svgs/times.svg", height: "12px", width: "12px", class: "mx-1"))
                concat(message)
              end
          end.join.html_safe
        end
      end
    end
  end
end
