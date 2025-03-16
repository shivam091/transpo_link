# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class FeedbacksController < ApplicationController

  # GET /feedbacks
  def index
    @feedbacks = Feedback.accessible(current_user)
    @feedbacks = case params[:status]
                 when "read"   then @feedbacks.read
                 when "unread" then @feedbacks.unread
                 else               @feedbacks
                 end
    @feedbacks, @pagination_metadata = @feedbacks.paginate(page: params[:page])
  end
end
