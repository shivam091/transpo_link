# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class FeedbacksController < ApplicationController
  before_action :set_breadcrumbs
  before_action :set_reviewable, only: [:new, :create]
  before_action :set_feedback, only: [:show, :mark_as_read]
  before_action :set_feedbacks, only: :index

  requires_authorization_for [:new, :create], :feedbacks, :create
  requires_authorization_for :mark_as_read, :feedbacks, :mark_as_read
  requires_authorization_for :show, :feedbacks, :view

  # GET /feedbacks
  def index
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

  def set_reviewable
    @reviewable = if params[:product_id]
      Product.find(params[:product_id])
    end
  end

  def set_feedback
    @feedback ||= Feedback.find(params[:id])
  end

  def set_feedbacks
    @feedbacks ||= Feedback.accessible(current_user)

    case params[:status]
    when "read"
      require_authorization :feedbacks, :view_read
      @feedbacks = @feedbacks.read
    when "unread"
      require_authorization :feedbacks, :view_unread
      @feedbacks = @feedbacks.unread
    else
      require_authorization :feedbacks, :view_all
    end

    @feedbacks
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
