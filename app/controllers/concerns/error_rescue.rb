# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module ErrorRescue
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::InvalidAuthenticityToken, with: :perform_sign_out_and_redirect
    unless Rails.application.config.consider_all_requests_local
      rescue_from Exception, with: :render_internal_server_error
    end
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from ApplicationError, with: :handle_application_error
    rescue_from AccessDeniedError, with: :render_forbidden
  end

  def render_not_found
    render "errors/not_found", status: :not_found, layout: "error"
  end

  private

  def handle_application_error(exception)
    Rails.logger.warn("[ApplicationError] #{exception.class}: #{exception.message}")
    flash[:alert] = exception.message

    redirect_back fallback_location: root_path
  end

  def perform_sign_out_and_redirect(exception)
    sign_out(current_user) if user_signed_in?

    redirect_to new_user_session_path
  end

  def render_internal_server_error(exception)
    Rails.logger.error("[500 Error Rescue] #{exception.message}")

    render "errors/internal_server_error", status: :internal_server_error, layout: "error"
  end

  def render_forbidden
    render "errors/forbidden", status: :forbidden, layout: "error"
  end
end
