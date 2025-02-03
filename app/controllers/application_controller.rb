# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true

  layout proc { false if request.xhr? }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Trackable

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    if user_signed_in?
      sign_out(current_user)
    else
      redirect_to new_user_session_path
    end
  end

  before_action :authenticate_user!

  around_action :set_locale, :set_time_zone

  def render_flash
    turbo_stream.update(:flash, partial: "shared/flash_messages")
  end

  private

  def set_locale(&block)
    if user_signed_in?
      TranspoLink::I18n.with_user_locale(current_user, &block)
    else
      TranspoLink::I18n.with_default_locale(&block)
    end
  end

  def set_time_zone(&block)
    if user_signed_in?
      Time.use_zone(current_user.preferred_time_zone, &block)
    else
      Time.use_zone(Time.zone_default, &block)
    end
  end
end
