# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :user_detail do
    first_name { "TranspoLink" }
    sequence(:last_name) { |n| "User #{n}" }
    mobile_number { generate(:mobile_number) }
    alternate_contact_number { generate(:phone_number) }
    alternate_email { generate(:email) }
    association :user
  end
end
