# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :user do
    password { Rails.application.credentials.config[:TEST_PASSWORD] }
    password_confirmation { Rails.application.credentials.config[:TEST_PASSWORD] }

    factory :admin, parent: :user do
      email { "admin@transpo-link.com" }
      role { ::Role.find_by(name: "admin") || create(:admin_role, :active) }
    end

    factory :buyer, parent: :user do
      email { "buyer@transpo-link.com" }
      role { ::Role.find_by(name: "buyer") || create(:buyer_role, :active) }
    end

    factory :supplier, parent: :user do
      email { "supplier@transpo-link.com" }
      role { ::Role.find_by(name: "supplier") || create(:supplier_role, :active) }
    end

    trait :confirmed do
      unconfirmed_email { "" }
      confirmation_token { nil }
      confirmed_at { DateTime.current }
      confirmation_sent_at { nil }
    end

    trait :banned do
      is_banned { true }
    end
  end
end
