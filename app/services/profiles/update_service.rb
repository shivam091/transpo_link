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
      ServiceResponse.success(payload: {user:})
    else
      ServiceResponse.error(payload: {user:})
    end
  end
end
