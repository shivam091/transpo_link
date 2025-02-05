# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Profiles::UpdateService < ApplicationService
  def initialize(user, profile_attributes)
    @user = user
    @profile_attributes = profile_attributes
  end

  def call
    update_profile
  end

  private

  attr_reader :user, :profile_attributes

  def update_profile
    if user.update(profile_attributes)
      ServiceResponse.success(message: t("profiles.update.success"), payload: {user: user})
    else
      ServiceResponse.error(message: t("profiles.update.error"), payload: {user: user})
    end
  end
end
