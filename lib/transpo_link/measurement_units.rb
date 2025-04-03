# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  module MeasurementUnits
    extend self

    UNITS = {
      count:  %i[item pack box carton pallet bundle dz case roll],
      length: %i[mm cm m km in ft yd mi],
      weight: %i[mg g kg q t lb oz],
      area:   %i[cm² m² km² in² ft² yd² ac ha],
      volume: %i[ml L cm³ m³ in³ ft³ gal pt qt bbl],
    }.with_indifferent_access.freeze

    def select_options(category = nil)
      target_units = category ? {category => units_for(category)} : UNITS

      target_units.map do |category, units|
        [
          ::I18n.t(category, scope: "measurement_units.categories"),
          units.map(&:to_s).map do |unit|
            [::I18n.t(unit, scope: "measurement_units.sub_categories"), unit]
          end
        ]
      end.to_h
    end

    def all_units
      UNITS.values.flatten
    end

    def units_for(category)
      UNITS[category] || []
    end

    def category_for_unit(unit)
      UNITS.find { |category, units| units.include?(unit.to_sym) }&.first
    end

    def display_label(count, unit)
      ::I18n.t(unit, scope: "measurement_units.display_labels", count: count)
    end
  end
end
