# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PreferencesController < ApplicationController

  # GET /preference
  def show
  end

  # GET /preference/edit
  def edit
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
          render turbo_stream: [
            turbo_stream.update(:edit_preference_form_frame, partial: "preferences/form"),
            render_flash
          ], status: :unprocessable_entity
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
        :are_notifications_enabled
      ]
    )
  end
end
