# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/color_schemes_helper_spec.rb

require "spec_helper"

RSpec.describe ColorSchemesHelper, type: :helper do
  it { is_expected.to have_constant(:COLOR_SCHEME_ICONS) }

  describe "#default" do
    it "returns default icon 'system'" do
      expect(ColorSchemesHelper::COLOR_SCHEME_ICONS.default).to eq("system")
    end
  end

  describe "#color_scheme_icon_for" do
    it "returns 'system' for :auto" do
      expect(helper.color_scheme_icon_for(:auto)).to eq("system")
    end

    it "returns 'sun' for :light" do
      expect(helper.color_scheme_icon_for(:light)).to eq("sun")
    end

    it "returns 'moon' for :dark" do
      expect(helper.color_scheme_icon_for(:dark)).to eq("moon")
    end

    it "returns 'system' for string 'auto'" do
      expect(helper.color_scheme_icon_for("auto")).to eq("system")
    end

    it "returns 'sun' for string 'light'" do
      expect(helper.color_scheme_icon_for("light")).to eq("sun")
    end

    it "returns 'moon' for string 'dark'" do
      expect(helper.color_scheme_icon_for("dark")).to eq("moon")
    end

    it "returns default icon 'system' for invalid key" do
      expect(helper.color_scheme_icon_for(:unknown)).to eq("system")
      expect(helper.color_scheme_icon_for("unexpected")).to eq("system")
      expect(helper.color_scheme_icon_for(nil)).to eq("system")
    end
  end
end
