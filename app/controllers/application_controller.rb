# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ApplicationController < ActionController::Base
  include TurboStreamHelpers, Breadcrumbs, FlashMessages

  protect_from_forgery with: :exception, prepend: true

  layout proc { false if request.xhr? }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    sign_out(current_user) if user_signed_in?

    redirect_to new_user_session_path
  end
  rescue_from ApplicationError, with: :handle_application_error

  prepend_before_action :authenticate_user!
  before_action :set_main_breadcrumb
  before_action :check_if_banned, :update_last_activity_at, if: :user_signed_in?

  around_action :with_locale, :with_time_zone

  private

  def with_locale(&block)
    if user_signed_in?
      TranspoLink::I18n.with_user_locale(current_user, &block)
    else
      TranspoLink::I18n.with_default_locale(&block)
    end
  end

  def with_time_zone(&block)
    if user_signed_in?
      TranspoLink::TimeZone.with_user_time_zone(current_user, &block)
    else
      TranspoLink::TimeZone.with_default_time_zone(&block)
    end
  end

  def set_main_breadcrumb
    add_breadcrumb t("dashboards.breadcrumb"), root_path
  end

  # Ensures that the user is not banned after authentication.
  def check_if_banned
    if current_user.is_banned?
      sign_out current_user
      set_flash_message(:alert, :suspended, scope: "devise.failure")

      redirect_to new_user_session_path
    end
  end

  def handle_application_error(exception)
    Rails.logger.warn("[ApplicationError] #{exception.class}: #{exception.message}")
    flash[:alert] = exception.message

    redirect_back fallback_location: root_path
  end

  def update_last_activity_at
    current_user.update_last_activity_at
  end
end
