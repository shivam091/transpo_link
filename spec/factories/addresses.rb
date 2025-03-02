# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :address do
    address1 { "Sector 18" }
    address2 { "New Panvel" }
    city { "Navi Mumbai" }
    state { "MH" }
    country { "IN" }
    postal_code { "410206" }

    trait :for_user do
      association :addressable, factory: :admin
    end

    trait :for_warehouse do
      association :addressable, factory: :warehouse
    end
  end
end
