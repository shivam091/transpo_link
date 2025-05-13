# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :unit do
    symbol { "u" }
    category { :count }

    trait :count do
      category { :count }
    end

    trait :weight do
      category { :weight }
    end

    trait :length do
      category { :length }
    end

    trait :area do
      category { :area }
    end

    trait :volume do
      category { :volume }
    end

    factory :dozen_unit, traits: [:count] do
      symbol { "dz" }
    end

    factory :item_unit, traits: [:count] do
      symbol { "item" }
    end

    factory :kilogramme_unit, traits: [:weight] do
      symbol { "kg" }
    end

    factory :gramme_unit, traits: [:weight] do
      symbol { "g" }
    end

    factory :kilometre_unit, traits: [:length] do
      symbol { "km" }
    end

    factory :metre_unit, traits: [:length] do
      symbol { "m" }
    end

    factory :acre_unit, traits: [:area] do
      symbol { "ac" }
    end

    factory :hectare_unit, traits: [:area] do
      symbol { "ha" }
    end

    factory :litre_unit, traits: [:volume] do
      symbol { "L" }
    end

    factory :millilitre_unit, traits: [:volume] do
      symbol { "ml" }
    end
  end
end
