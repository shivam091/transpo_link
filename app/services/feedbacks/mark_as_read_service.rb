# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Feedbacks::MarkAsReadService < ApplicationService
  def initialize(feedback)
    @feedback = feedback
  end

  def call
    mark_as_read
  end

  private

  attr_reader :feedback

  def mark_as_read
    if feedback.mark_as_read!
      ServiceResponse.success(payload: {feedback:})
    else
      ServiceResponse.error(payload: {feedback:})
    end
  end
end
