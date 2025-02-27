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
                concat(external_svg_tag("svgs/cancel.svg", height: "12px", width: "12px", class: "mx-1"))
                concat(message)
              end
          end.join.html_safe
        end
      end
    end
  end

  def help_text(*args, &block)
    if block_given?
      build_help_text(capture(&block), *args)
    else
      build_help_text(*args)
    end
  end

  private

  def build_help_text(help_text, help_tag = :small)
    return unless help_text.present?

    content_tag(help_tag, help_text, class: "form-text text-muted")
  end
end
