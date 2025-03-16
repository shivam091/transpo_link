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

  # GET /feedbacks/:reviewable_id/new
  def new
    @reviewable = find_reviewable
    @feedback = @reviewable.feedbacks.build
  end

  # POST /feedbacks/:reviewable_id
  def create
    @reviewable = find_reviewable
    response = Feedbacks::CreateService.(current_user, @reviewable, feedback_params)
    @feedback = response.payload[:feedback]

    if response.success?
      set_flash_message(:notice, :success)
      redirect_to request.referrer, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(:new_feedback_form_frame, partial: "feedbacks/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rating, :comment)
  end

  def find_reviewable
    if params[:product_id]
      Product.find(params[:product_id])
    end
  end
end
