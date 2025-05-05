# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :user_detail, class: "User::Detail" do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    mobile_number { Faker::PhoneNumber.cell_phone_in_e164 }
    alternate_contact_number { Faker::PhoneNumber.phone_number_with_country_code }
    alternate_email { Faker::Internet.email }
    association :user
  end
end
