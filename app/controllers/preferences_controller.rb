# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PreferencesController < ApplicationController
  before_action :set_breadcrumbs, :set_user

  requires_authorization_for [:edit, :update], :preferences, :update
  requires_authorization_for :show, :preferences, :view

  # GET /preference
  def show
  end

  # GET /preference/edit
  def edit
    add_breadcrumb t(".breadcrumb"), edit_preference_path(current_user)
  end

  # PUT|PATCH /preference
  def update
    response = Preferences::UpdateService.(current_user, preference_params)

    if response.success?
      set_flash_message(:notice, :success)

      redirect_to preference_path, status: :see_other
    else
      set_flash_message(:alert, :error, immediate: true)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [update_form_frame, render_flash], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def preference_params
    params.require(:user).permit(
      user_preference_attributes: [
        :preferred_locale,
        :preferred_time_zone,
        :preferred_currency,
        :preferred_color_scheme,
        :preferred_date_format,
        :preferred_time_format,
        :preferred_datetime_format,
        :first_day_of_week,
        :are_notifications_enabled,
        :enable_keyboard_shortcuts
      ]
    )
  end

  def set_breadcrumbs
    add_breadcrumb t("preferences.breadcrumb"), preference_path
  end

  def set_user
    @user = current_user
  end

  def form_frame_id
    :edit_preference_form_frame
  end

  def form_partial
    "preferences/form"
  end
end
