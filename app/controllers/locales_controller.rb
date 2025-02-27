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
      flash[:notice] = response.message
      redirect_to request.referrer
    else
      flash.now[:alert] = response.message
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
      user_preference_attributes: [
        :preferred_locale,
      ]
    )
  end
end
