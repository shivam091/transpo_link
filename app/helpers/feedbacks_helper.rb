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

    conditional_link_to(can_view_reviewable?(reviewable), path, **options) do
      label
    end
  end

  def can_view_reviewable?(reviewable)
    model_key = reviewable.class.name.underscore.pluralize.to_sym
    authorized_for?(model_key, :view)
  end
end
