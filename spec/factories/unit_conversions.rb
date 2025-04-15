# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

FactoryBot.define do
  factory :unit_conversion do
    association :source_unit, factory: :dozen_unit
    association :target_unit, factory: :item_unit
    multiplier { 12.0 }

    factory :dozen_item_conversion do
      association :source_unit, factory: :dozen_unit
      association :target_unit, factory: :item_unit
      multiplier { 12.0 }
    end

    factory :kilogramme_gramme_conversion do
      association :source_unit, factory: :kilogramme_unit
      association :target_unit, factory: :gramme_unit
      multiplier { 1_000.0 }
    end

    factory :metre_kilometre_conversion do
      association :source_unit, factory: :metre_unit
      association :target_unit, factory: :kilometre_unit
      multiplier { 0.001 }
    end

    factory :acre_hectare_conversion do
      association :source_unit, factory: :acre_unit
      association :target_unit, factory: :hectare_unit
      multiplier { 0.404686 }
    end

    factory :litre_millilitre_conversion do
      association :source_unit, factory: :litre_unit
      association :target_unit, factory: :millilitre_unit
      multiplier { 1_000.0 }
    end
  end
end
