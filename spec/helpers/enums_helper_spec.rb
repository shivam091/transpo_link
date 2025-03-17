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
        {light: 0, dark: 1, auto: 2}
      end

      def self.model_name
        ActiveModel::Name.new(self, nil, "Preference")
      end
    end

    allow(I18n).to receive(:t).with("light", scope: "enumerations.preference.color_schemes") { "Light" }
    allow(I18n).to receive(:t).with("dark", scope: "enumerations.preference.color_schemes") { "Dark" }
    allow(I18n).to receive(:t).with("auto", scope: "enumerations.preference.color_schemes") { "Auto" }
  end

  describe "#enum_options_for_select" do
    let(:expected_result) { [["Light", 0], ["Dark", 1], ["Auto", 2]] }

    it "returns an array of translated enum options with their values" do
      expect(helper.enum_options_for_select(Preference, :color_scheme)).to eq(expected_result)
    end
  end

  describe "#enum_l" do
    let(:preference) { Preference.new(color_scheme: :dark) }

    it "returns the translated string for the current enum value of a model" do
      expect(helper.enum_l(preference, :color_scheme)).to eq("Dark")
    end
  end

  describe "#enum_i18n" do
    it "returns the translated string for a given enum key" do
      expect(helper.enum_i18n(Preference, :color_scheme, :auto)).to eq("Auto")
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
