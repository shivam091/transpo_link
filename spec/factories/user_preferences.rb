# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :user_preference do
    preferred_color_scheme { "auto" }
    preferred_locale { "en" }
    preferred_time_zone { "Asia/Kolkata" }
    preferred_currency { "INR" }
    are_notifications_enabled { true }
    association :user
  end
end
