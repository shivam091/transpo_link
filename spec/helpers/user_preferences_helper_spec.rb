# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/user_preferences_helper_spec.rb

require "spec_helper"

RSpec.describe UserPreferencesHelper, type: :helper do
  describe "#selectable_locales_with_translation_level" do
    before do
      allow(TranspoLink::I18n).to receive(:selectable_locales).and_return({
        en: "English",
        fr: "French - Français"
      })
      allow(TranspoLink::I18n).to receive(:percentage_translated_for).with(:en).and_return(100)
      allow(TranspoLink::I18n).to receive(:percentage_translated_for).with(:fr).and_return(10)
    end

    it "returns locales that meet the translation threshold with formatted strings" do
      expect(helper).to receive(:t).with(".language_translation_percentage", locale: :en).and_return("%{language} (%{percent_translated})")
      expect(helper).to receive(:t).with(".language_translation_percentage", locale: :fr).and_return("%{language} (%{percent_translated})")

      result = helper.selectable_locales_with_translation_level(1)

      expect(result).to eq([
        ["English (100%)", :en],
        ["French - Français (10%)", :fr]
      ])
    end
  end
end
