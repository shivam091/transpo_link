# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UserPreference < ApplicationRecord
  self.primary_key = :user_id

  enum :preferred_color_scheme, {
    auto: "auto",
    dark: "dark",
    light: "light"
  }

  attribute :preferred_color_scheme, :enum, default: preferred_color_schemes[:auto]
  attribute :preferred_locale, default: I18n.default_locale
  attribute :preferred_time_zone, default: Time.zone.name
  attribute :preferred_currency, default: Money.default_currency.iso_code
  attribute :are_notifications_enabled, default: true

  validates :user_id,
            presence: true,
            reduce: true
  validates :preferred_locale,
            presence: true,
            inclusion: {in: I18n.available_locales.map(&:to_s)},
            reduce: true
  validates :preferred_color_scheme,
            presence: true,
            inclusion: {in: preferred_color_schemes.values},
            reduce: true
  validates :preferred_time_zone, :preferred_currency,
            presence: true,
            reduce: true

  belongs_to :user, inverse_of: :user_preference, touch: true
end
