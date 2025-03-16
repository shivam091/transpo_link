# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class FeedbacksController < ApplicationController

  # GET /feedbacks
  def index
    @feedbacks = Feedback.accessible(current_user)
    @feedbacks, @pagination_metadata = @feedbacks.paginate(page: params[:page])
  end
end
