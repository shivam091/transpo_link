# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ApplicationController < ActionController::Base
  include Breadcrumbs, FlashMessages

  protect_from_forgery with: :exception, prepend: true

  layout proc { false if request.xhr? }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    if user_signed_in?
      sign_out(current_user)
    else
      redirect_to new_user_session_path
    end
  end

  before_action :authenticate_user!, :set_main_breadcrumb

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
end
