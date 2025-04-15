# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/number_helper_spec.rb

require "spec_helper"

RSpec.describe NumberHelper, type: :helper do
  describe "#number_to_angle" do
    let(:default_options) do
      {
        precision: nil,
        strip_insignificant_zeros: true,
        delimiter: ",",
        separator: ".",
        format: "%{n}°",
      }
    end

    before do
      allow(I18n).to receive(:t).with("number.angle", default: {}) { default_options }
    end

    it "handles zero correctly" do
      expect(helper.number_to_angle(0)).to eq("0°")
    end

    it "returns nil when number is nil" do
      expect(helper.number_to_angle(nil)).to be_nil
    end

    it "returns the number with a degree symbol" do
      expect(helper.number_to_angle(45)).to eq("45°")
    end

    it "returns formatted number with precision" do
      expect(helper.number_to_angle(45.678, precision: 1)).to eq("45.7°")
    end

    it "handles custom format correctly" do
      expect(helper.number_to_angle(45.678, precision: 2, format: "%{n} degrees")).to eq("45.68 degrees")
    end

    it "formats with a delimiter and separator correctly" do
      expect(helper.number_to_angle(1234567.89, delimiter: ".", separator: ",", precision: 2)).to eq("1.234.567,89°")
    end

    it "strips insignificant zeros if strip_insignificant_zeros is true" do
      expect(helper.number_to_angle(45.00)).to eq("45°")
    end

    it "does not strip insignificant zeros if strip_insignificant_zeros is false" do
      expect(helper.number_to_angle(45.00, strip_insignificant_zeros: false)).to eq("45.0°")
    end

    it "handles negative numbers correctly" do
      expect(helper.number_to_angle(-45)).to eq("-45°")
    end
  end

  describe "#number_to_measurement_unit" do
    let(:default_options) do
      {
        format: "%{n} %{u}",
        precision: 2,
        strip_insignificant_zeros: false,
        delimiter: ",",
        separator: ".",
        units: {
          ft: {
            one: "foot",
            other: "feet"
          },
          m: {
            one: "metre",
            other: "metres"
          },
          kg: {
            one: "kilogramme",
            other: "kilogrammes"
          }
        }
      }
    end

    before do
      allow(I18n).to receive(:t).with("number.measurement_unit", default: {}) { default_options }
    end

    it "returns nil when number is nil" do
      expect(helper.number_to_measurement_unit(nil, :ft)).to be_nil
    end

    it "returns nil when unit is blank" do
      expect(helper.number_to_measurement_unit(5, nil)).to be_nil
    end

    it "formats singular correctly (1 foot)" do
      expect(helper.number_to_measurement_unit(1, :ft)).to eq("1.00 foot")
    end

    it "formats plural correctly (2 feet)" do
      expect(helper.number_to_measurement_unit(2, :ft)).to eq("2.00 feet")
    end

    it "handles floating-point numbers correctly (0.99 feet)" do
      expect(helper.number_to_measurement_unit(0.99, :ft)).to eq("0.99 feet")
    end

    it "handles zero correctly (0 feet)" do
      expect(helper.number_to_measurement_unit(0, :ft)).to eq("0.00 feet")
    end

    it "formats with a delimiter (1,000 feet)" do
      expect(helper.number_to_measurement_unit(1000, :ft)).to eq("1,000.00 feet")
    end

    it "formats using default precision (1.00 metres)" do
      expect(helper.number_to_measurement_unit(1, :m)).to eq("1.00 metre")
    end

    it "formats floating-point numbers correctly (1.50 metres)" do
      expect(helper.number_to_measurement_unit(1.5, :m)).to eq("1.50 metres")
    end

    it "respects strip_insignificant_zeros when false (1.00 metres)" do
      expect(helper.number_to_measurement_unit(1.00, :m)).to eq("1.00 metre")
    end

    it "respects strip_insignificant_zeros when true (1 metre)" do
      expect(helper.number_to_measurement_unit(1.00, :m, strip_insignificant_zeros: true)).to eq("1 metre")
    end

    it "formats with a custom separator and delimiter (1.234,56 kg)" do
      expect(helper.number_to_measurement_unit(1234.56, :kg, delimiter: ".", separator: ",")).to eq("1.234,56 kilogrammes")
    end

    it "handles custom format correctly" do
      expect(helper.number_to_measurement_unit(45.678, :kg, format: "%{u} %{n}")).to eq("kilogrammes 45.68")
    end

    it "handles negative numbers correctly (-5 feet)" do
      expect(helper.number_to_measurement_unit(-5, :ft)).to eq("-5.00 feet")
    end

    it "handles missing unit key gracefully" do
      expect { helper.number_to_measurement_unit(5, :unknown) }.to raise_error(KeyError)
    end

    it "handles missing 'one' or 'other' key in unit hash" do
      modified_options = default_options.deep_dup
      modified_options[:units][:ft].delete(:one)

      allow(I18n).to receive(:t).with("number.measurement_unit", default: {}) { modified_options }

      expect { helper.number_to_measurement_unit(1, :ft) }.to raise_error(KeyError)
    end

    it "handles an empty units hash" do
      allow(I18n).to receive(:t).with("number.measurement_unit", default: {}) { default_options.merge(units: {}) }

      expect { helper.number_to_measurement_unit(1, :ft) }.to raise_error(KeyError)
    end

    it "handles large numbers correctly" do
      expect(helper.number_to_measurement_unit(1_000_000, :ft)).to eq("1,000,000.00 feet")
    end

    it "handles extreme floating-point precision" do
      expect(helper.number_to_measurement_unit(1.9999, :m)).to eq("2.00 metres")
    end

    it "handles multiple options being overridden correctly" do
      expect(helper.number_to_measurement_unit(1234.56, :kg, precision: 1, delimiter: ".", separator: ",")).to eq("1.234,6 kilogrammes")
    end
  end
end
