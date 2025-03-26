# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :user_preference do
    preferred_color_scheme { UserPreference.preferred_color_schemes.keys.sample }
    preferred_locale { "en" }
    preferred_time_zone { Faker::Address.time_zone }
    preferred_currency { Faker::Currency.code }
    are_notifications_enabled { Faker::Boolean.boolean }
    association :user
  end
end
