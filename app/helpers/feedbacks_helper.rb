# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for feedbacks module.
#
module FeedbacksHelper
  def reviewable_name_with_type(reviewable)
    "#{reviewable.name} (#{reviewable.class.name})"
  end

  def reviewable_link(reviewable)
    case reviewable
    when Product   then product_path(reviewable)
    else                "javascript:void(0)"
    end
  end
end
