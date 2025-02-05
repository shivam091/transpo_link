# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Preferences::UpdateService < ApplicationService
  def initialize(user, preference_attributes)
    @user, @preference_attributes = user, preference_attributes
  end

  def call
    update_preference
  end

  private

  attr_reader :user, :preference_attributes

  def update_preference
    if user.update(preference_attributes)
      ServiceResponse.success(message: t("preferences.update.success"), payload: {user: user})
    else
      ServiceResponse.error(message: t("preferences.update.error"), payload: {user: user})
    end
  end
end
