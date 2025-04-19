# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/color_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::Color do
  describe "#initialize" do
    it "strips and freezes the value" do
      color = color_obj("  #ff00aa  ")

      expect(color.to_s).to eq("#ff00aa")
      expect(color.to_s).to be_frozen
    end

    it "accepts another Color instance" do
      color1 = color_obj("#ff00aa")
      color2 = color_obj(color1)

      expect(color2).to eq(color1)
    end
  end

  describe "#valid?" do
    it "returns true for valid short hex color" do
      expect(color_obj("#f0a").valid?).to be_truthy
    end

    it "returns true for valid hex color with alpha" do
      expect(color_obj("#f0a8").valid?).to be_truthy
    end

    it "returns true for valid full hex color" do
      expect(color_obj("#ff00aa").valid?).to be_truthy
    end

    it "returns true for valid full hex color with alpha" do
      expect(color_obj("#ff00aaff").valid?).to be_truthy
    end

    it "returns false for invalid hex color" do
      expect(color_obj("invalid").valid?).to be_falsy
    end
  end

  describe "#rgba" do
    it "parses short hex (#123) into RGBA" do
      expect(color_obj("#123").rgba).to eq([17, 34, 51, 1.0])
    end

    it "parses hex with alpha (#1234) into RGBA" do
      expect(color_obj("#1234").rgba).to eq([17, 34, 51, 0.27])
    end

    it "parses hex with alpha (#112233) into RGBA" do
      expect(color_obj("#112233").rgba).to eq([17, 34, 51, 1.0])
    end

    it "parses full hex (#11223344) into RGBA" do
      expect(color_obj("#11223344").rgba).to eq([17, 34, 51, 0.27])
    end

    it "returns empty array for invalid input" do
      expect(color_obj("invalid").rgba).to eq([])
    end
  end

  describe "#hsla" do
    it "converts HEX to HSLA" do
      expect(color_obj("#ff0000").hsla).to eq([0, 100, 50, 1.0])
    end

    it "returns correct HSLA for gray HEX (#888888)" do
      expect(color_obj("#888888").hsla).to eq([0, 0, 53, 1.0])
    end
  end

  describe "#rgba_scaled" do
    it "returns RGBA values with alpha scaled to 255" do
      expect(color_obj("#ff00aaff").rgba_scaled).to eq([255, 0, 170, 255])
      expect(color_obj("#f0a8").rgba_scaled).to eq([255, 0, 170, 135])
    end

    it "returns RGBA values with alpha as 255 for fully opaque colors" do
      expect(color_obj("#ff00aa").rgba_scaled).to eq([255, 0, 170, 255])
    end

    it "returns empty array for invalid input" do
      expect(color_obj("invalid").rgba_scaled).to eq([])
    end
  end

  describe "#hsla_scaled" do
    it "returns HSLA values with alpha scaled to 255" do
      expect(color_obj("#ff0000ff").hsla_scaled).to eq([0, 100, 50, 255])
      expect(color_obj("#f08a").hsla_scaled).to eq([328, 100, 50, 255]) # approximate values
    end

    it "returns HSLA values with alpha as 255 for fully opaque colors" do
      expect(color_obj("#ff0000").hsla_scaled).to eq([0, 100, 50, 255])
    end
  end

  describe "#to_s" do
    it "returns the original string value" do
      expect(color_obj("#ff00aa").to_s).to eq("#ff00aa")
    end
  end

  describe "#as_json" do
    it "returns the string representation" do
      expect(color_obj("#f0a").as_json).to eq("#f0a")
    end
  end

  describe "#==" do
    it "returns true for same color values" do
      expect(color_obj("#ff00aa")).to eq(color_obj("#ff00aa"))
    end

    it "returns false for different color values" do
      expect(color_obj("#ff00aa")).not_to eq(color_obj("#00ffaa"))
    end

    it "returns false for objects of different classes" do
      expect(color_obj("#ff00aa")).not_to eq("#ff00aa")
    end
  end

  def color_obj(hex)
    described_class.new(hex)
  end
end

RSpec.describe TranspoLink::Color::Converter do
  describe ".hex_to_rgba" do
    it "converts red HEX to RGBA" do
      expect(described_class.hex_to_rgba("#f000")).to eq([255, 0, 0, 0.0])
    end

    it "converts green HEX to RGBA" do
      expect(described_class.hex_to_rgba("#00800000")).to eq([0, 128, 0, 0.0])
    end

    it "converts blue HEX to RGBA" do
      expect(described_class.hex_to_rgba("#00f0")).to eq([0, 0, 255, 0.0])
    end

    it "converts gray HEX to RGBA" do
      expect(described_class.hex_to_rgba("#80808000")).to eq([128, 128, 128, 0.0])
    end

    it "converts white HEX to RGBA" do
      expect(described_class.hex_to_rgba("#fff0")).to eq([255, 255, 255, 0.0])
    end

    it "converts black HEX to RGBA" do
      expect(described_class.hex_to_rgba("#0000")).to eq([0, 0, 0, 0.0])
    end
  end

  describe ".rgba_to_hsla" do
    it "converts red RGBA to HSLA" do
      expect(described_class.rgba_to_hsla(255, 0, 0)).to eq([0, 100, 50, 1.0])
    end

    it "converts green RGBA to HSLA" do
      expect(described_class.rgba_to_hsla(0, 255, 0)).to eq([120, 100, 50, 1.0])
    end

    it "converts blue RGBA to HSLA" do
      expect(described_class.rgba_to_hsla(0, 0, 255)).to eq([240, 100, 50, 1.0])
    end

    it "converts gray RGBA to HSLA" do
      expect(described_class.rgba_to_hsla(136, 136, 136)).to eq([0, 0, 53, 1.0])
    end

    it "converts white RGBA to HSLA" do
      expect(described_class.rgba_to_hsla(255, 255, 255)).to eq([0, 0, 100, 1.0])
    end

    it "converts black RGBA to HSLA" do
      expect(described_class.rgba_to_hsla(0, 0, 0)).to eq([0, 0, 0, 1.0])
    end
  end

  describe ".hsla_to_rgba" do
    it "converts red HSLA to RGBA" do
      expect(described_class.hsla_to_rgba(0, 100, 50, 1)).to eq([255, 0, 0, 1.0])
    end

    it "converts green HSLA to RGBA" do
      expect(described_class.hsla_to_rgba(120, 100, 50, 1)).to eq([0, 255, 0, 1.0])
    end

    it "converts blue HSLA to RGBA" do
      expect(described_class.hsla_to_rgba(240, 100, 50, 1)).to eq([0, 0, 255, 1.0])
    end

    it "converts gray HSLA to RGBA" do
      expect(described_class.hsla_to_rgba(0, 0, 53, 1)).to eq([135, 135, 135, 1.0])
    end

    it "converts white HSLA to RGBA" do
      expect(described_class.hsla_to_rgba(0, 0, 100, 1)).to eq([255, 255, 255, 1.0])
    end

    it "converts black HSLA to RGBA" do
      expect(described_class.hsla_to_rgba(0, 0, 0, 1)).to eq([0, 0, 0, 1.0])
    end
  end

  describe ".rgba_to_hex" do
    it "converts red RGBA to HEX" do
      expect(described_class.rgba_to_hex(255, 0, 0, 0.0)).to eq("#f000")
    end

    it "converts green RGBA to HEX" do
      expect(described_class.rgba_to_hex(0, 128, 0, 0.0)).to eq("#00800000")
    end

    it "converts blue RGBA to HEX" do
      expect(described_class.rgba_to_hex(0, 0, 255, 0.0)).to eq("#00f0")
    end

    it "converts gray RGBA to HEX" do
      expect(described_class.rgba_to_hex(128, 128, 128, 0.0)).to eq("#80808000")
    end

    it "converts white RGBA to HEX" do
      expect(described_class.rgba_to_hex(255, 255, 255, 0.0)).to eq("#fff0")
    end

    it "converts black RGBA to HEX" do
      expect(described_class.rgba_to_hex(0, 0, 0, 0.0)).to eq("#0000")
    end

    it "pads hex values with zeros correctly" do
      expect(described_class.rgba_to_hex(1, 2, 3)).to eq("#010203")
    end
  end
end
