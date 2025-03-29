# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :request_log do
    uuid { Faker::Internet.uuid }
    uri { "http://www.example.com" }
    add_attribute(:method) { "get" }
    query_params { {} }
    session_id { Faker::Number.number(digits: 20) }
    session_private_id { Faker::Number.number(digits: 20) }
    remote_address { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    referrer { "http://www.example.com" }
    origin { "http://www.example.com" }
    memory_usage { 194944 }
    cpu_usage { 1.1 }
    ip_info { {} }
    request_headers { {} }
    response_headers { {} }
    status { 200 }
    response_size { 9902 }
    exception { {} }
    elapsed_time { 0.0572.to_f }
    user { nil }

    trait :with_user do
      association :user, factory: :admin
    end
  end
end
