# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class LocalesController < ApplicationController
  # GET /locale/edit
  def edit
  end

  # PUT|PATCH /locale
  def update
    response = Locales::UpdateService.(current_user, locale_params)

    if response.success?
      set_flash_message(:notice, :success)

      redirect_back fallback_location: root_path, status: :see_other
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

  def locale_params
    params.require(:user).permit(
      user_preference_attributes: [
        :preferred_locale,
      ]
    )
  end

  def form_frame_id
    :edit_locale_form_frame
  end

  def form_partial
    "locales/form"
  end
end
