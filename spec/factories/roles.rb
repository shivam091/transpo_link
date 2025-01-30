# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :role do
    factory :admin_role, parent: :role do
      name { "admin" }
    end

    factory :buyer_role, parent: :role do
      name { "buyer" }
    end

    factory :supplier_role, parent: :role do
      name { "supplier" }
    end
  end
end
