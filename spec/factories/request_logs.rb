# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :request_log do
    uuid { SecureRandom.uuid }
    add_attribute(:method) { "get" }
    uri { "http://www.example.com" }
    remote_address { "127.0.0.1" }
    elapsed_time { 0.0572.to_f }
    user_agent { "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36" }
    referrer { "http://www.example.com" }
    origin { "http://www.example.com" }
    memory_usage { 194944 }
    cpu_usage { 1.1 }
    exception { {}.to_json }
    request_headers { {}.to_json }
    response_headers { {}.to_json }
    status { 200 }
    response_size { 9902 }
    query_params { {}.to_json }
    ip_info { {}.to_json }
  end
end
