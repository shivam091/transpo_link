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
          render turbo_stream: [
            turbo_stream.update(:edit_locale_form_frame, partial: "locales/form"),
            render_flash
          ], status: :unprocessable_entity
        end
      end
    end
  end

  private

  def locale_params
    params.require(:user).permit(
      preference_attributes: [
        :preferred_locale,
      ]
    )
  end
end
