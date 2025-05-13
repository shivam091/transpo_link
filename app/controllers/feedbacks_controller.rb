# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class FeedbacksController < ApplicationController
  before_action :set_breadcrumbs
  before_action :find_reviewable, only: [:new, :create]
  before_action :find_feedback, only: [:show, :mark_as_read]

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
    @feedback = @reviewable.feedbacks.build
  end

  # POST /feedbacks/:reviewable_id
  def create
    response = Feedbacks::CreateService.(current_user, @reviewable, feedback_params)
    @feedback = response.payload[:feedback]

    if response.success?
      set_flash_message(:notice, :success)

      redirect_back fallback_location: feedbacks_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  # PUT|PATCH /feedbacks/:id/mark-as-read
  def mark_as_read
    response = Feedbacks::MarkAsReadService.(@feedback)
    @feedback = response.payload[:feedback]

    if response.success?
      set_flash_message(:info, :success)
    else
      set_flash_message(:alert, :error)
    end

    redirect_back fallback_location: feedbacks_path, status: :see_other
  end

  # GET /feedbacks/:id
  def show
    add_breadcrumb @feedback.reference_code, :feedbacks_path
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rating, :comment)
  end

  def find_reviewable
    @reviewable = if params[:product_id]
      Product.find(params[:product_id])
    end
  end

  def find_feedback
    @feedback ||= Feedback.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb t("feedbacks.breadcrumb"), feedbacks_path
  end

  def form_frame_id
    :new_feedback_form_frame
  end

  def form_partial
    "feedbacks/form"
  end
end
