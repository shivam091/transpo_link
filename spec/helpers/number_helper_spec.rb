# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/number_helper_spec.rb

require "spec_helper"

RSpec.describe NumberHelper, type: :helper do
  describe "#number_to_angle" do
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
end
