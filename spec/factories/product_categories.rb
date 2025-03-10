# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :product_category do
    sequence(:name) { |n| "Product category #{n}" }

    factory :product_sub_category, parent: :product_category do
      association :parent_category, factory: :product_category
    end
  end
end
