# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Locales::UpdateService < ApplicationService
  def initialize(user, locale_attributes)
    @user = user
    @locale_attributes = locale_attributes
  end

  def call
    update_locale
  end

  private

  attr_reader :user, :locale_attributes

  def update_locale
    if user.update(locale_attributes)
      TranspoLink::I18n.locale = user.preferred_locale
      ServiceResponse.success(message: t("locales.update.notice"), payload: {user: user})
    else
      ServiceResponse.error(message: t("locales.update.alert"), payload: {user: user})
    end
  end
end
