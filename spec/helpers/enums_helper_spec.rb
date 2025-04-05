# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/enums_helper_spec.rb

require "spec_helper"

RSpec.describe EnumsHelper, type: :helper do
  before do
    class Preference
      include ActiveModel::Model

      attr_accessor :color_scheme

      def self.color_schemes
        {light: 0, dark: 1, system: 2}
      end
    end

    allow(I18n).to receive(:t).with("light", scope: "enumerations.preference.color_schemes", default: "Light") { "Light mode" }
    allow(I18n).to receive(:t).with("dark", scope: "enumerations.preference.color_schemes", default: "Dark") { "Dark mode" }
    allow(I18n).to receive(:t).with("system", scope: "enumerations.preference.color_schemes", default: "System") { "System preferred" }
  end

  describe "#enum_options_for_select" do
    let(:expected_result) { [["Light mode", 0], ["Dark mode", 1], ["System preferred", 2]] }

    it "returns an array of translated enum options with their values" do
      expect(helper.enum_options_for_select(Preference, :color_scheme)).to eq(expected_result)
    end
  end

  describe "#enum_l" do
    context "when key is present" do
      let!(:preference) { Preference.new(color_scheme: :dark) }

      it "returns the translated string for the current enum value of a model" do
        expect(helper.enum_l(preference, :color_scheme)).to eq("Dark mode")
      end
    end

    context "when key is not present" do
      let!(:preference) { Preference.new(color_scheme: nil) }

      it "returns nil" do
        expect(helper.enum_l(preference, :color_scheme)).to be_nil
      end
    end
  end

  describe "#enum_i18n" do
    it "returns the translated string for a given enum key" do
      expect(helper.enum_i18n(Preference, :color_scheme, :system)).to eq("System preferred")
    end
  end

  describe "#enum_key" do
    it "returns the enum key for a given value" do
      expect(helper.enum_key(Preference, :color_scheme, 1)).to eq(:dark)
    end

    it "returns nil if the value does not exist" do
      expect(helper.enum_key(Preference, :color_scheme, 99)).to be_nil
    end
  end
end
