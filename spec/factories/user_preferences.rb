# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :user_preference do
    preferred_color_scheme { :light }
    preferred_locale { "en" }
    preferred_time_zone { Faker::Address.time_zone }
    preferred_currency { Faker::Currency.code }
    preferred_date_format { "long" }
    preferred_time_format { "twenty_four_hours_long" }
    preferred_datetime_format { "long_with_seconds" }
    first_day_of_week { UserPreference.first_day_of_weeks.keys.sample }
    are_notifications_enabled { Faker::Boolean.boolean }
    enable_keyboard_shortcuts { Faker::Boolean.boolean }
    association :user
  end
end
