# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ColorSchemesController < ApplicationController

  # PUT|PATCH /color-scheme
  def update
    response = ColorSchemes::UpdateService.(current_user, params[:color_scheme])

    if response.http_status == :ok
      render json: response.payload, status: :ok
    elsif response.http_status == :bad_request
      render json: {error: t(:bad_request, scope:)}, status: :bad_request
    else
      render json: {error: t(:unprocessable_entity, scope:)}, status: :unprocessable_entity
    end
  end

  private

  def scope
    "flashes.color_schemes.update"
  end
end
