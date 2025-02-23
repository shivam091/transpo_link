# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/measurement_units_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::MeasurementUnits do
  describe "::UNITS" do
    it "is a frozen hash" do
      expect(described_class::UNITS).to be_frozen
    end

    it "allows access using symbols and strings" do
      expect(described_class::UNITS[:area]).to eq(%i[cm² m² km² in² ft² yd² ac ha])
      expect(described_class::UNITS["area"]).to eq(%i[cm² m² km² in² ft² yd² ac ha])
    end
  end

  describe ".options_for_units" do
    before do
      allow(I18n).to receive(:t) { |key, **| key.to_s.humanize }

      allow(I18n).to receive(:t).with("area", scope: "measurement_units.categories").and_return("Area")
      allow(I18n).to receive(:t).with("weight", scope: "measurement_units.categories").and_return("Weight")
      allow(I18n).to receive(:t).with("volume", scope: "measurement_units.categories").and_return("Volume")
      allow(I18n).to receive(:t).with("length", scope: "measurement_units.categories").and_return("Length")
      allow(I18n).to receive(:t).with("count", scope: "measurement_units.categories").and_return("Count")

      allow(I18n).to receive(:t).with("cm²", scope: "measurement_units.sub_categories").and_return("Square Centimeter")
      allow(I18n).to receive(:t).with("kg", scope: "measurement_units.sub_categories").and_return("Kilogram")
      allow(I18n).to receive(:t).with("L", scope: "measurement_units.sub_categories").and_return("Liter")
      allow(I18n).to receive(:t).with("m", scope: "measurement_units.sub_categories").and_return("Meter")
      allow(I18n).to receive(:t).with("item", scope: "measurement_units.sub_categories").and_return("Item")
    end

    it "returns a hash with translated categories and subcategories" do
      result = described_class.options_for_units

      expect(result).to be_a(Hash)
      expect(result.keys).to contain_exactly("Area", "Weight", "Volume", "Length", "Count")

      expect(result["Area"]).to include(["Square Centimeter", "cm²"])
      expect(result["Weight"]).to include(["Kilogram", "kg"])
      expect(result["Volume"]).to include(["Liter", "L"])
      expect(result["Length"]).to include(["Meter", "m"])
      expect(result["Count"]).to include(["Item", "item"])
    end
  end

  describe ".all_units" do
    it "returns a flattened array of all measurement units" do
      expected_units = [
        :cm², :m², :km², :in², :ft², :yd², :ac, :ha,
        :mg, :g, :kg, :q, :t, :lb, :oz,
        :ml, :L, :cm³, :m³, :in³, :ft³, :gal, :pt, :qt, :bbl,
        :mm, :cm, :m, :km, :in, :ft, :yd, :mi,
        :item, :pack, :box, :carton, :pallet, :bundle, :dz, :case, :roll
      ]

      expect(described_class.all_units).to match_array(expected_units)
    end

    it "returns an array" do
      expect(described_class.all_units).to be_an(Array)
    end

    it "does not contain duplicates" do
      expect(described_class.all_units.uniq.length).to eq(described_class.all_units.length)
    end
  end
end
