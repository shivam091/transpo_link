# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/measurement_units_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::MeasurementUnits do
  let(:all_units) do
    [
      :cm², :m², :km², :in², :ft², :yd², :ac, :ha,
      :mg, :g, :kg, :q, :t, :lb, :oz,
      :ml, :L, :cm³, :m³, :in³, :ft³, :gal, :pt, :qt, :bbl,
      :mm, :cm, :m, :km, :in, :ft, :yd, :mi,
      :item, :pack, :box, :carton, :pallet, :bundle, :dz, :case, :roll
    ]
  end
  let(:area_units) { %i[cm² m² km² in² ft² yd² ac ha] }
  let(:count_units) { %i[item pack box carton pallet bundle dz case roll] }

  describe "::UNITS" do
    it "is a frozen array" do
      expect(described_class::UNITS).to be_frozen
    end

    it "allows access using symbols and strings" do
      expect(described_class::UNITS[:area]).to eq(area_units)
      expect(described_class::UNITS["area"]).to eq(area_units)
    end
  end

  describe ".select_options" do
    before do
      allow(I18n).to receive(:t) { |key, **| key.to_s.humanize }

      allow(I18n).to receive(:t).with("area", scope: "measurement_units.categories") { "Area" }
      allow(I18n).to receive(:t).with("weight", scope: "measurement_units.categories") { "Weight" }
      allow(I18n).to receive(:t).with("volume", scope: "measurement_units.categories") { "Volume" }
      allow(I18n).to receive(:t).with("length", scope: "measurement_units.categories") { "Length" }
      allow(I18n).to receive(:t).with("count", scope: "measurement_units.categories") { "Count" }

      allow(I18n).to receive(:t).with("cm²", scope: "measurement_units.sub_categories") { "Square Centimeter" }
      allow(I18n).to receive(:t).with("kg", scope: "measurement_units.sub_categories") { "Kilogram" }
      allow(I18n).to receive(:t).with("L", scope: "measurement_units.sub_categories") { "Liter" }
      allow(I18n).to receive(:t).with("m", scope: "measurement_units.sub_categories") { "Meter" }
      allow(I18n).to receive(:t).with("item", scope: "measurement_units.sub_categories") { "Item" }
    end

    let(:result) { described_class.select_options }

    it "returns a hash with translated categories and subcategories" do
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
      expect(described_class.all_units).to match_array(all_units)
    end

    it "returns an array" do
      expect(described_class.all_units).to be_an(Array)
    end

    it "does not contain duplicates" do
      expect(described_class.all_units.uniq.length).to eq(described_class.all_units.length)
    end
  end

  describe ".units_for" do
    it "returns an array of units for the specified category" do
      expect(described_class.units_for(:count)).to eq(count_units)
    end

    it "returns an empty array if the specified category is invalid" do
      expect(described_class.units_for(:angle)).to be_empty
    end
  end

  describe ".category_for_unit" do
    it "returns the correct category for a unit" do
      expect(described_class.category_for_unit(:kg)).to eq("weight")
      expect(described_class.category_for_unit(:m²)).to eq("area")
      expect(described_class.category_for_unit(:bbl)).to eq("volume")
      expect(described_class.category_for_unit(:item)).to eq("count")
    end

    it "returns nil for a unit not found in any category" do
      expect(described_class.category_for_unit(:xyz)).to be_nil
    end
  end

  describe ".display_label" do
    before do
      allow(I18n).to receive(:t) do |key, scope:, count:|
        translations = {
          "measurement_units.display_labels.item" => {one: "1 item", other: "%{count} items"},
          "measurement_units.display_labels.pack" => {one: "1 pack", other: "%{count} packs"},
          "measurement_units.display_labels.box" => {one: "1 box", other: "%{count} boxes"},
          "measurement_units.display_labels.kg" => {one: "1 kilogramme", other: "%{count} kilogrammes"},
          "measurement_units.display_labels.cm²" => {one: "1 sq. centimetre", other: "%{count} sq. centimetres"}
        }
        translation = translations["#{scope}.#{key}"]
        count == 1 ? translation[:one] : translation[:other] % { count: count }
      end
    end

    it "returns the singular label for count 1" do
      expect(described_class.display_label(1, :item)).to eq("1 item")
      expect(described_class.display_label(1, :pack)).to eq("1 pack")
      expect(described_class.display_label(1, :box)).to eq("1 box")
      expect(described_class.display_label(1, :kg)).to eq("1 kilogramme")
      expect(described_class.display_label(1, :cm²)).to eq("1 sq. centimetre")
    end

    it "returns the plural label for count greater than 1" do
      expect(described_class.display_label(5, :item)).to eq("5 items")
      expect(described_class.display_label(5, :pack)).to eq("5 packs")
      expect(described_class.display_label(5, :box)).to eq("5 boxes")
      expect(described_class.display_label(5, :kg)).to eq("5 kilogrammes")
      expect(described_class.display_label(5, :cm²)).to eq("5 sq. centimetres")
    end
  end
end
