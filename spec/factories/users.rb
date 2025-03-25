# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email(domain: "transpo-link.com") }
    password { Rails.application.credentials.config[:TEST_PASSWORD] }
    password_confirmation { Rails.application.credentials.config[:TEST_PASSWORD] }
    last_activity_at { nil }
    password_updated_at { DateTime.now }
    is_active { false }
    is_banned { false }

    factory :admin, parent: :user do
      role { Role.find_by(name: "admin") || create(:admin_role, :active) }
    end

    factory :buyer, parent: :user do
      role { Role.find_by(name: "buyer") || create(:buyer_role, :active) }
    end

    factory :supplier, parent: :user do
      role { Role.find_by(name: "supplier") || create(:supplier_role, :active) }
    end

    factory :manager, parent: :user do
      role { Role.find_by(name: "manager") || create(:manager_role, :active) }
    end

    after(:create) do |user|
      create(:user_detail, user: user)
      create(:user_preference, user: user)
    end

    trait :confirmed do
      unconfirmed_email { "" }
      confirmation_token { nil }
      confirmed_at { DateTime.current }
      confirmation_sent_at { nil }
    end

    trait :suspended do
      is_banned { true }
    end
  end
end
