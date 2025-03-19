# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Feedbacks::CreateService < ApplicationService
  def initialize(user, reviewable, feedback_attributes)
    @user = user
    @reviewable = reviewable
    @feedback_attributes = feedback_attributes
  end

  def call
    create_feedback
  end

  private

  attr_reader :user, :reviewable, :feedback_attributes

  def create_feedback
    feedback = reviewable.feedbacks.build(user: user, **feedback_attributes)

    if feedback.save
      ServiceResponse.success(payload: {feedback:, reviewable:})
    else
      ServiceResponse.error(payload: {feedback:, reviewable:})
    end
  end
end
