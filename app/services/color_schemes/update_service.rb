# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ColorSchemes::UpdateService < ApplicationService
  include ColorSchemesHelper

  def initialize(user, color_scheme)
    @user = user
    @color_scheme = color_scheme
  end

  def call
    update_color_scheme
  end

  private

  attr_reader :user, :color_scheme

  def update_color_scheme
    if user.update(preferred_color_scheme: color_scheme)
      ServiceResponse.success(payload: {color_scheme:, icon: color_scheme_icon_for(color_scheme)})
    elsif !UserPreference.preferred_color_schemes.key?(color_scheme)
      ServiceResponse.error(http_status: :bad_request)
    else
      ServiceResponse.error(payload: {user:})
    end
  end
end
