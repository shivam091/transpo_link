# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ColorSchemesController < ApplicationController
  def update
    color_scheme = params[:color_scheme]

    unless UserPreference.preferred_color_schemes.key?(color_scheme)
      render json: {error: "Invalid color scheme"}, status: :unprocessable_entity and return
    end

    if current_user.user_preference.update!(preferred_color_scheme: color_scheme)
      render json: {
        preferred_color_scheme: color_scheme,
        icon: view_context.color_scheme_icon_for(color_scheme)
      }, status: :ok
    else
      render json: {error: "Failed to update the color scheme"}, status: :unprocessable_entity
    end
  end
end
