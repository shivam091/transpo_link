# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# rake transpo_link:db:add_unit_conversions RAILS_ENV=XXX

desc "Seed units & conversions used in TranspoLink"
namespace :transpo_link do
  namespace :db do
    UNITS_AND_CONVERSIONS = {
      count: {
        item:  {
          pack: 0.16666666666666666,
          box: 0.041666666666666664,
          carton: 0.020833333333333332,
          pallet: 0.0020833333333333333,
          bundle: 0.08333333333333333,
          dz: 0.08333333333333333,
          case: 0.027777777777777776,
          roll: 0.041666666666666664
        },
        pack:   {item: 6, box: 0.25, carton: 0.125, pallet: 0.0125, bundle: 0.5, dz: 0.5, case: 0.08333333333333333, roll: 0.25},
        box:    {item: 24, pack: 4, carton: 0.5, pallet: 0.05, bundle: 2, dz: 2, case: 0.3333333333333333, roll: 1},
        carton: {item: 48, pack: 8, box: 2, pallet: 0.1, bundle: 4, dz: 4, case: 1.5, roll: 2},
        pallet: {item: 480, pack: 80, box: 20, carton: 10, bundle: 40, dz: 40, case: 6.67, roll: 20},
        bundle: {item: 12, pack: 2, box: 0.5, carton: 0.25, pallet: 0.025, dz: 1, case: 0.16666666666666666, roll: 0.5},
        dz:     {item: 12, pack: 2, box: 0.5, carton: 0.25, pallet: 0.025, bundle: 1, case: 0.16666666666666666, roll: 0.5},
        case:   {item: 36, pack: 12, box: 3, carton: 1.5, pallet: 6.67, bundle: 6, dz: 6, roll: 3},
        roll:   {item: 24, pack: 4, box: 1, carton: 0.5, pallet: 0.05, bundle: 2, dz: 2, case: 0.3333333333333333}
      },
      length: {
        mm: {cm: 0.1, m: 0.001, km: 0.000001, in: 0.0393701, ft: 0.00328084, yd: 0.00109361, mi: 0.000000621371},
        cm: {mm: 10, m: 0.01, km: 0.00001, in: 0.393701, ft: 0.0328084, yd: 0.0109361, mi: 0.00000621371},
        m:  {mm: 1_000, cm: 100, km: 0.001, in: 39.3701, ft: 3.28084, yd: 1.09361, mi: 0.000621371},
        km: {mm: 1_000_000, cm: 100_000, m: 1_000, in: 39_370.1, ft: 3_280.84, yd: 1_093.61, mi: 0.621371},
        in: {mm: 25.4, cm: 2.54, m: 0.0254, km: 0.0000254, ft: 0.0833333, yd: 0.0277778, mi: 0.0000157828},
        ft: {mm: 304.8, cm: 30.48, m: 0.3048, km: 0.0003048, in: 12, yd: 0.333333, mi: 0.000189394},
        yd: {mm: 914.4, cm: 91.44, m: 0.9144, km: 0.0009144, in: 36, ft: 3, mi: 0.000568182},
        mi: {mm: 1_609_344, cm: 160_934.4, m: 1_609.34, km: 1.60934, in: 63_360, ft: 5_280, yd: 1_760}
      },
      weight: {
        mg: {g: 0.001, kg: 0.000001, q: 0.00000001, t: 0.000000001, lb: 0.00000220462, oz: 0.000035274},
        g:  {mg: 1_000, kg: 0.001, q: 0.00001, t: 0.000001, lb: 0.00220462, oz: 0.035274},
        kg: {mg: 1_000_000, g: 1000, q: 0.01, t: 0.001, lb: 2.20462, oz: 35.274},
        q:  {mg: 100_000_000, g: 100_000, kg: 100, t: 0.1, lb: 220.462, oz: 3_527.4},
        t:  {mg: 1_000_000_000, g: 1_000_000, kg: 1_000, q: 10, lb: 2_204.62, oz: 35_274},
        lb: {mg: 453_592, g: 453.592, kg: 0.453592, q: 0.00453592, t: 0.000453592, oz: 16},
        oz: {mg: 28_349.5, g: 28.3495, kg: 0.0283495, q: 0.000283495, t: 0.0000283495, lb: 0.0625}
      },
      area: {
        cm²: {m²: 0.0001, km²: 0.0000000001, in²: 0.155, ft²: 0.00107639, yd²: 0.000119599, ac: 0.00000002471, ha: 0.00000001},
        m²:  {cm²: 10_000, km²: 0.000001, in²: 1_550.003, ft²: 10.7639, yd²: 1.19599, ac: 0.000247105, ha: 0.0001},
        km²: {cm²: 10_000_000_000, m²: 1_000_000, in²: 1_550_003_100, ft²: 10_763_910, yd²: 1_195_990, ac: 247.105, ha: 100},
        in²: {cm²: 6.4516, m²: 0.00064516, km²: 0.00000000064516, ft²: 0.00694444, yd²: 0.000771605, ac: 0.00000015942, ha: 0.000000064516},
        ft²: {cm²: 929.03, m²: 0.092903, km²: 0.000000092903, in²: 144, yd²: 0.111111, ac: 0.0000229568, ha: 0.0000092903},
        yd²: {cm²: 8_361, m²: 0.836127, km²: 0.000000836127, in²: 1_296, ft²: 9, ac: 0.000206612, ha: 0.0000836127},
        ac:  {cm²: 40_468_564.2, m²: 4_046.86, km²: 0.00404686, in²: 6_272_640, ft²: 43_560, yd²: 4_840, ha: 0.404686},
        ha:  {cm²: 100_000_000, m²: 10_000, km²: 0.01, in²: 15_500_031, ft²: 107_639, yd²: 11_959.9, ac: 2.47105}
      },
      volume: {
        ml:  {L: 0.001, cm³: 1, m³: 0.000001, in³: 0.0610237, ft³: 0.0000353147, gal: 0.000264172, pt: 0.00211338, qt: 0.00105669, bbl: 0.00000628981},
        L:   {ml: 1_000, cm³: 1000, m³: 0.001, in³: 61.0237, ft³: 0.0353147, gal: 0.264172, pt: 2.11338, qt: 1.05669, bbl: 0.00628981 },
        cm³: {ml: 1, L: 0.001, m³: 0.000001, in³: 0.0610237, ft³: 0.0000353147, gal: 0.000264172, pt: 0.00211338, qt: 0.00105669, bbl: 0.00000628981},
        m³:  {ml: 1_000_000, L: 1_000, cm³: 1_000_000, in³: 61023.7, ft³: 35.3147, gal: 264.172, pt: 2113.38, qt: 1056.69, bbl: 6.28981},
        in³: {ml: 16.3871, L: 0.0163871, cm³: 16.3871, m³: 0.0000163871, ft³: 0.000578704, gal: 0.004329, pt: 0.034632, qt: 0.017316, bbl: 0.000103072},
        ft³: {ml: 28_316.8, L: 28.3168, cm³: 28_316.8, m³: 0.0283168, in³: 1728, gal: 7.48052, pt: 59.8442, qt: 29.9221, bbl: 0.178107},
        gal: {ml: 3_785.41, L: 3.78541, cm³: 3_785.41, m³: 0.00378541, in³: 231, ft³: 0.133681, pt: 8, qt: 4, bbl: 0.0238095},
        pt:  {ml: 473.176, L: 0.473176, cm³: 473.176, m³: 0.000473176, in³: 28.875, ft³: 0.0167101, gal: 0.125, qt: 0.5, bbl: 0.00297619},
        qt:  {ml: 946.353, L: 0.946353, cm³: 946.353, m³: 0.000946353, in³: 57.75, ft³: 0.0334201, gal: 0.25, pt: 2, bbl: 0.00595238},
        bbl: {ml: 158_987, L: 158.987, cm³: 158_987, m³: 0.158987, in³: 9_702, ft³: 5.61458, gal: 42, pt: 336, qt: 168}
      }
    }

    task add_unit_conversions: :environment do
      unit_records = {}

      puts "↳ Adding units and conversions..."

      UNITS_AND_CONVERSIONS.each do |category, units|
        units.each_key do |symbol|
          unit = Unit.safe_find_or_create_by(symbol: symbol.to_s, category: category.to_s)
          unit_records[symbol] = unit
        end

        # Create conversions
        units.each do |from_symbol, target_units|
          source_unit = unit_records[from_symbol]

          target_units.each do |to_symbol, multiplier|
            target_unit = unit_records[to_symbol]

            existing = UnitConversion.find_by(source_unit: source_unit, target_unit: target_unit)
            next if existing

            UnitConversion.create!(
              source_unit: source_unit,
              target_unit: target_unit,
              multiplier: multiplier
            )
          end
        end
      end

      puts "↳ Added units and conversions."
    end
  end
end
