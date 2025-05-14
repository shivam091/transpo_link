# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for feedbacks module.
#
module FeedbacksHelper
  def reviewable_label(reviewable)
    "#{reviewable.name} (#{reviewable.class.name})"
  end

  def reviewable_path(reviewable)
    case reviewable
    when Product    then product_path(reviewable)
    else                 "javascript:void(0)"
    end
  end

  def link_to_reviewable(reviewable, **options)
    label = reviewable_label(reviewable)
    path = reviewable_path(reviewable)

    link_to(label, path, **options)
  end
end
